import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice/domain/practice_models.dart';
import '../data/audio_playback_service.dart';

/// UI が表示する音声プレイヤーの状態。
enum AudioPlayerStatus {
  idle,
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
}

/// 音源、時間、速度、繰り返し、活性文をまとめた immutable State。
class AudioPlayerState {
  const AudioPlayerState({
    this.status = AudioPlayerStatus.idle,
    this.questionId,
    this.sentences = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1,
    this.repeatMode = RepeatMode.none,
    this.activeSentenceId,
    this.errorMessage,
  });

  final AudioPlayerStatus status;
  final String? questionId;
  final List<TranscriptSentence> sentences;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double speed;
  final RepeatMode repeatMode;
  final String? activeSentenceId;
  final String? errorMessage;

  /// 操作可能な音源が設定済みかを返します。
  bool get hasSource => questionId != null;

  /// UI 上の再生状態が playing かを返します。
  bool get isPlaying => status == AudioPlayerStatus.playing;

  /// 指定項目だけを更新した新しい State を返します。
  ///
  /// nullable 項目には明示的な clear フラグを設け、未指定と null への変更を区別します。
  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    String? questionId,
    bool clearQuestionId = false,
    List<TranscriptSentence>? sentences,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    RepeatMode? repeatMode,
    String? activeSentenceId,
    bool clearActiveSentence = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      questionId: clearQuestionId ? null : questionId ?? this.questionId,
      sentences: sentences ?? this.sentences,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      repeatMode: repeatMode ?? this.repeatMode,
      activeSentenceId: clearActiveSentence
          ? null
          : activeSentenceId ?? this.activeSentenceId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// 音声サービスの Stream を購読し、再生操作と本文同期を管理する Notifier。
///
/// AudioPlaybackService のイベントを [AudioPlayerState] へ変換し、Widget は
/// ref.watch だけで現在位置や再生状態を描画できます。
class AudioPlayerController extends Notifier<AudioPlayerState> {
  late final AudioPlaybackService _service;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _loopSeekInProgress = false;
  String? _sentenceLoopTargetId;
  String? _currentAudioAssetPath;
  int _sourceRequestId = 0;

  @override
  AudioPlayerState build() {
    _service = ref.watch(audioPlaybackServiceProvider);
    // 複数の Plugin Stream を単一 State へ集約し、UI 側の購読を簡潔にします。
    _subscriptions
      ..add(_service.positionStream.listen(_onPosition))
      ..add(
        _service.bufferedPositionStream.listen(
          (position) => state = state.copyWith(bufferedPosition: position),
        ),
      )
      ..add(
        _service.durationStream.listen((duration) {
          // loadAssetの戻り値を確定値とし、古い音源から遅れて届くdurationは無視します。
          if (duration != null && state.status == AudioPlayerStatus.loading) {
            state = state.copyWith(duration: duration);
          }
        }),
      )
      ..add(_service.stateStream.listen(_onEngineState));
    ref.onDispose(() {
      // Provider の破棄後にイベントが届かないよう、すべての購読を解除します。
      _sourceRequestId++;
      for (final subscription in _subscriptions) {
        unawaited(subscription.cancel());
      }
    });
    return const AudioPlayerState();
  }

  /// 問題の音源と時間付き本文を読み込み、速度と保存位置を復元します。
  Future<void> loadQuestion(
    Question question, {
    double speed = 1,
    Duration restorePosition = Duration.zero,
  }) async {
    // 同じ問題が正常に読み込み済みなら、不要な音源再設定を行いません。
    if (state.questionId == question.id &&
        state.status != AudioPlayerStatus.error) {
      return;
    }
    final requestId = ++_sourceRequestId;
    _currentAudioAssetPath = question.audioAssetPath;
    state = AudioPlayerState(
      status: AudioPlayerStatus.loading,
      questionId: question.id,
      sentences: question.sentences,
      speed: speed,
    );
    _sentenceLoopTargetId = null;
    try {
      // 前の問題のループ設定を解除してから、新しい Asset を読み込みます。
      await _service.setQuestionLooping(false);
      if (requestId != _sourceRequestId) return;
      final duration = await _service.loadAsset(question.audioAssetPath);
      if (requestId != _sourceRequestId) return;
      await _service.setSpeed(speed);
      if (requestId != _sourceRequestId) return;
      final safePosition = restorePosition < duration
          ? restorePosition
          : Duration.zero;
      // 音源長を超えた保存位置は使用せず、先頭から再生できる状態へ戻します。
      if (safePosition > Duration.zero) {
        await _service.seek(safePosition);
        if (requestId != _sourceRequestId) return;
      }
      state = state.copyWith(
        status: AudioPlayerStatus.ready,
        duration: duration,
        position: safePosition,
        activeSentenceId: question.hasCompleteTimeline
            ? findActiveSentence(question.sentences, safePosition)?.id
            : null,
        clearActiveSentence: !question.hasCompleteTimeline,
        clearError: true,
      );
    } catch (error) {
      // 新しいrequestが開始済みなら、古いloadの完了やerrorをStateへ反映しません。
      if (requestId != _sourceRequestId) return;
      state = state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: '音声を読み込めませんでした。\n$error',
      );
    }
  }

  /// 現在状態に応じて再生と一時停止を切り替えます。
  Future<void> togglePlayPause() async {
    if (!state.hasSource || state.status == AudioPlayerStatus.loading) return;
    try {
      if (state.isPlaying) {
        await _service.pause();
      } else {
        // 再生完了後の再開は、音源先頭へ戻してから行います。
        if (state.status == AudioPlayerStatus.completed) {
          await _service.seek(Duration.zero);
        }
        await _service.play();
      }
    } catch (error) {
      state = state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: '再生できませんでした。\n$error',
      );
    }
  }

  /// 指定位置を音源範囲内へ補正して seek します。
  Future<void> seek(Duration position) async {
    if (!state.hasSource ||
        state.status == AudioPlayerStatus.idle ||
        state.status == AudioPlayerStatus.loading ||
        state.status == AudioPlayerStatus.error) {
      return;
    }
    final max = state.duration;
    final safe = position < Duration.zero
        ? Duration.zero
        : position > max
        ? max
        : position;
    final requestId = _sourceRequestId;
    await _service.seek(safe);
    if (requestId != _sourceRequestId) return;
    final wasCompleted = state.status == AudioPlayerStatus.completed;
    _onPosition(safe);
    // 終端からseekした後は自動再生せず、次の再生時にseek位置から開始できる状態へ戻します。
    if (wasCompleted && safe < max) {
      state = state.copyWith(status: AudioPlayerStatus.paused);
    }
  }

  /// 指定文の開始時刻へ seek します。
  Future<void> seekToSentence(TranscriptSentence sentence) async {
    final startMs = sentence.startMs;
    final endMs = sentence.endMs;
    final before = state.position;
    final wasPlaying = state.isPlaying;
    final sourceReady = state.hasSource &&
        state.status != AudioPlayerStatus.idle &&
        state.status != AudioPlayerStatus.loading &&
        state.status != AudioPlayerStatus.error;
    final belongsToCurrentQuestion = state.sentences.any(
      (item) => item.id == sentence.id && item.startMs == startMs,
    );
    final durationMs = state.duration.inMilliseconds;
    final requestId = _sourceRequestId;

    // 問題別音声では各ファイル先頭を0msとした相対時刻だけを受け付けます。
    // 音源読込前、別問題の文、不正範囲では誤ったAudioPlayer位置へ移動させません。
    if (!sourceReady ||
        !belongsToCurrentQuestion ||
        startMs == null ||
        endMs == null ||
        startMs < 0 ||
        endMs <= startMs ||
        durationMs <= 0 ||
        startMs > durationMs ||
        endMs > durationMs) {
      _debugSentenceSeek(
        sentence: sentence,
        before: before,
        after: state.position,
        wasPlaying: wasPlaying,
        result: 'rejected',
      );
      return;
    }

    await seek(Duration(milliseconds: startMs));
    if (requestId != _sourceRequestId) return;
    if (wasPlaying && !_service.playing) {
      // 通常just_audioのseekは再生を継続しますが、Platform側で停止した場合だけ復帰します。
      await _service.play();
    }
    // _onPositionがseek位置からactiveSentenceIdを再計算し、UIと実位置を一致させます。
    _debugSentenceSeek(
      sentence: sentence,
      before: before,
      after: state.position,
      wasPlaying: wasPlaying,
      result: 'completed',
    );
  }

  /// 音声サービスと表示 State の再生速度を同期して更新します。
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  /// リピートなし、現在文、現在問題の順にモードを切り替えます。
  Future<void> cycleRepeatMode() async {
    final hasTimeline =
        state.sentences.isNotEmpty &&
        state.sentences.every(
          (sentence) => sentence.startMs != null && sentence.endMs != null,
        );
    // 文時間がない教材では文repeatを飛ばし、問題全体repeatだけを提供します。
    final next = switch (state.repeatMode) {
      RepeatMode.none =>
        hasTimeline ? RepeatMode.sentence : RepeatMode.question,
      RepeatMode.sentence => RepeatMode.question,
      RepeatMode.question => RepeatMode.none,
    };
    await _service.setQuestionLooping(next == RepeatMode.question);
    _sentenceLoopTargetId = next == RepeatMode.sentence
        ? state.activeSentenceId
        : null;
    state = state.copyWith(repeatMode: next);
  }

  /// 再生を停止し、画面へ公開する State を初期状態へ戻します。
  Future<void> stop() async {
    final requestId = ++_sourceRequestId;
    await _service.stop();
    if (requestId != _sourceRequestId) return;
    _sentenceLoopTargetId = null;
    _currentAudioAssetPath = null;
    state = const AudioPlayerState();
  }

  void _debugSentenceSeek({
    required TranscriptSentence sentence,
    required Duration before,
    required Duration after,
    required bool wasPlaying,
    required String result,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'seekToSentence: result=$result, questionId=${state.questionId}, '
      'sentenceId=${sentence.id}, startMs=${sentence.startMs}, '
      'positionBeforeMs=${before.inMilliseconds}, '
      'positionAfterMs=${after.inMilliseconds}, '
      'audioDurationMs=${state.duration.inMilliseconds}, '
      'audioAsset=$_currentAudioAssetPath, '
      'playingBefore=$wasPlaying, playingAfter=${state.isPlaying}',
    );
  }

  void _onPosition(Duration position) {
    // setAsset中は旧音源のposition eventが届く可能性があるため、新問題のStateへ反映しません。
    if (state.status == AudioPlayerStatus.idle ||
        state.status == AudioPlayerStatus.loading ||
        state.status == AudioPlayerStatus.error) {
      return;
    }
    final active = findActiveSentence(state.sentences, position);
    if (state.repeatMode == RepeatMode.sentence && active != null) {
      _sentenceLoopTargetId = active.id;
    }
    state = state.copyWith(
      position: position,
      activeSentenceId: active?.id,
      clearActiveSentence: active == null,
    );
    final loopTarget = _sentenceLoopTargetId == null
        ? null
        : state.sentences
              .where((sentence) => sentence.id == _sentenceLoopTargetId)
              .firstOrNull;
    // 文の終了後は active が null になるため、直前の対象 ID を保持して開始位置へ戻します。
    // 非同期 seek の重複発行は _loopSeekInProgress で防ぎます。
    if (state.repeatMode == RepeatMode.sentence &&
        loopTarget != null &&
        loopTarget.startMs != null &&
        loopTarget.endMs != null &&
        position.inMilliseconds >= loopTarget.endMs! &&
        position.inMilliseconds <= loopTarget.endMs! + 1000 &&
        !_loopSeekInProgress) {
      _loopSeekInProgress = true;
      unawaited(
        _service
            .seek(Duration(milliseconds: loopTarget.startMs!))
            .whenComplete(() => _loopSeekInProgress = false),
      );
    }
  }

  void _onEngineState(AudioEngineSnapshot snapshot) {
    // Plugin の processing と playing を組み合わせ、UI 向けの一意な状態へ変換します。
    final status = switch (snapshot.processing) {
      AudioEngineProcessing.idle =>
        state.hasSource ? AudioPlayerStatus.ready : AudioPlayerStatus.idle,
      AudioEngineProcessing.loading ||
      AudioEngineProcessing.buffering => AudioPlayerStatus.loading,
      AudioEngineProcessing.ready =>
        snapshot.playing
            ? AudioPlayerStatus.playing
            : state.status == AudioPlayerStatus.ready
            ? AudioPlayerStatus.ready
            : AudioPlayerStatus.paused,
      AudioEngineProcessing.completed => AudioPlayerStatus.completed,
    };
    state = state.copyWith(status: status);
  }
}

/// 再生位置に対応する文を二分探索で返します。
///
/// 判定区間は startMs を含み endMs を含みません。文間の空白では null を返します。
TranscriptSentence? findActiveSentence(
  List<TranscriptSentence> sentences,
  Duration position,
) {
  if (sentences.isEmpty ||
      sentences.any(
        (sentence) => sentence.startMs == null || sentence.endMs == null,
      )) {
    return null;
  }
  var low = 0;
  var high = sentences.length - 1;
  final milliseconds = position.inMilliseconds;
  while (low <= high) {
    final middle = low + ((high - low) >> 1);
    final sentence = sentences[middle];
    final startMs = sentence.startMs!;
    final endMs = sentence.endMs!;
    if (milliseconds < startMs) {
      high = middle - 1;
    } else if (milliseconds >= endMs) {
      low = middle + 1;
    } else {
      return sentence;
    }
  }
  return null;
}

/// 音声プレイヤーの State と操作 API をアプリ全体へ公開する Provider。
final audioPlayerControllerProvider =
    NotifierProvider<AudioPlayerController, AudioPlayerState>(
      AudioPlayerController.new,
    );
