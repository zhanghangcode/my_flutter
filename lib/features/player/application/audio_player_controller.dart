import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice/domain/practice_models.dart';
import 'audio_resource_resolver_provider.dart';
import '../data/audio_playback_service.dart';
import '../domain/audio_resource_resolver.dart';
import '../domain/audio_source_location.dart';
import '../domain/question_playback_mode.dart';

/// UI が表示する音声プレイヤーの状態。
enum AudioPlayerStatus {
  /// 音源未設定の初期状態です。
  idle,

  /// Asset音源を読み込んでいる状態です。
  loading,

  /// 音源の準備が完了し、まだ再生していない状態です。
  ready,

  /// 音声を出力している状態です。
  playing,

  /// 現在位置を保持して一時停止している状態です。
  paused,

  /// 音源末尾まで再生した状態です。
  completed,

  /// 読み込みまたは再生操作に失敗した状態です。
  error,
}

/// 音源、時間、速度、問題再生mode、活性文をまとめた immutable State。
class AudioPlayerState {
  /// UIへ公開する音声プレイヤーのimmutable Stateを生成します。
  ///
  /// すべて任意の引数で、未指定時は音源未設定・先頭位置・等速・順次再生の初期値を
  /// 使用します。[questionId]と[activeSentenceId]が`null`の場合は、それぞれ音源と
  /// 活性文が未確定であることを表します。生成時に音声操作の副作用はありません。
  const AudioPlayerState({
    this.status = AudioPlayerStatus.idle,
    this.questionId,
    this.sentences = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = 1,
    this.playbackMode = QuestionPlaybackMode.sequential,
    this.activeSentenceId,
    this.errorMessage,
  });

  /// 現在の読み込み・再生・失敗状態です。
  final AudioPlayerStatus status;

  /// 読み込み済み音源に対応する問題IDです。`null`は音源未設定を表します。
  final String? questionId;

  /// 現在問題のTranscript文一覧です。位置同期に使用します。
  final List<TranscriptSentence> sentences;

  /// 現在の再生位置です。
  final Duration position;

  /// 読み込み済み音源の総再生時間です。未確定時は[Duration.zero]です。
  final Duration duration;

  /// Native Playerがバッファ済みと通知した位置です。
  final Duration bufferedPosition;

  /// 現在音源へ適用した再生倍率です。
  final double speed;

  /// 問題完了時の連続再生ルールです。
  final QuestionPlaybackMode playbackMode;

  /// 再生位置に対応するTranscript文IDです。該当文がない時は`null`です。
  final String? activeSentenceId;

  /// 利用者へ表示する最後の音声エラーです。失敗していない時は`null`です。
  final String? errorMessage;

  /// 操作可能な音源が設定済みかを返します。
  bool get hasSource => questionId != null;

  /// UI 上の再生状態が playing かを返します。
  bool get isPlaying => status == AudioPlayerStatus.playing;

  /// 指定項目だけを更新した新しいStateを返します。
  ///
  /// nullable項目には明示的なclearフラグを設け、未指定と`null`への変更を区別します。
  /// [clearQuestionId]、[clearActiveSentence]、[clearError]が`true`の場合は対応する値を
  /// `null`へ更新します。元のStateは変更しません。
  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    String? questionId,
    bool clearQuestionId = false,
    List<TranscriptSentence>? sentences,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    QuestionPlaybackMode? playbackMode,
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
      playbackMode: playbackMode ?? this.playbackMode,
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
  /// Controllerが操作する音声サービスです。[build]でProviderから取得します。
  late final AudioPlaybackService _service;

  /// 教材metadataからAsset/File音源を解決するResolverです。
  late final AudioResourceResolver _resolver;

  /// AudioPlaybackServiceのStream購読一覧です。Provider破棄時にすべて解除します。
  final List<StreamSubscription<Object?>> _subscriptions = [];

  /// 現在読み込み中または読み込み済みの音源場所です。未設定時は`null`です。
  AudioSourceLocation? _currentAudioLocation;

  /// 新旧の非同期load結果を区別するための単調増加する要求IDです。
  int _sourceRequestId = 0;

  /// 問題切り替えで進行中のstop操作です。停止不要時は`null`です。
  Future<void>? _pendingStopOperation;

  @override
  /// 音声サービスの購読を開始し、初期Stateを返します。
  ///
  /// Provider初回作成時に呼ばれ、破棄時は購読を解除して遅延イベントによるState更新を防ぎます。
  AudioPlayerState build() {
    _service = ref.watch(audioPlaybackServiceProvider);
    _resolver = ref.watch(audioResourceResolverProvider);
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
          // loadSourceの戻り値を確定値とし、古い音源から遅れて届くdurationは無視します。
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
  ///
  /// [question]は音源とTranscriptを持つ対象問題、[speed]は適用する再生倍率、
  /// [restorePosition]は問題音声先頭からの復元位置、[playbackMode]は完了時の再生規則です。
  /// 同一問題が正常に準備済みなら再読込せず、古い非同期要求はrequest IDにより破棄します。
  Future<void> loadQuestion(
    Question question, {
    double speed = 1,
    Duration restorePosition = Duration.zero,
    QuestionPlaybackMode playbackMode = QuestionPlaybackMode.sequential,
  }) async {
    // 同じ問題が正常に読み込み済みなら、不要な音源再設定を行いません。
    if (state.questionId == question.id &&
        state.status != AudioPlayerStatus.error) {
      return;
    }
    final pendingStop = _pendingStopOperation;
    final requestId = ++_sourceRequestId;
    _currentAudioLocation = null;
    state = AudioPlayerState(
      status: AudioPlayerStatus.loading,
      questionId: question.id,
      sentences: question.sentences,
      speed: speed,
      playbackMode: playbackMode,
    );
    try {
      // 切り替え開始時のstopを待ってから新音源を設定し、Plugin操作の前後関係を保証します。
      if (pendingStop != null) await pendingStop;
      if (requestId != _sourceRequestId) return;
      final location = await _resolver.resolve(question);
      if (requestId != _sourceRequestId) return;
      _currentAudioLocation = location;
      // 問題単位のmodeだけをjust_audioへ反映し、問題間の連続再生は画面側で管理します。
      await _service.setQuestionLooping(
        playbackMode == QuestionPlaybackMode.repeatCurrent,
      );
      if (requestId != _sourceRequestId) return;
      final duration = await _service.loadSource(location);
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
    } on AudioResourceUnavailableException catch (error) {
      if (requestId != _sourceRequestId) return;
      state = state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: error.message,
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
  ///
  /// completed状態では先頭へ戻してから再生します。音源未設定・読み込み中・errorの場合は
  /// 何もせず、Plugin例外はerror StateとしてUIへ公開します。
  Future<void> togglePlayPause() async {
    if (!state.hasSource ||
        state.status == AudioPlayerStatus.idle ||
        state.status == AudioPlayerStatus.loading ||
        state.status == AudioPlayerStatus.error) {
      return;
    }
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

  /// 指定位置を音源範囲内へ補正してseekします。
  ///
  /// [position]は移動先のDurationです。範囲外は`0`から音源末尾へ丸め、読み込み中・失敗中・
  /// 音源未設定時は何も行いません。completedからの移動後はpausedへ戻します。
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

  /// 指定文の開始時刻へseekします。
  ///
  /// [sentence]が現在問題に属し、有効なmilliseconds時間と音源範囲を持つ場合だけ実行します。
  /// 再生中にPlatform側で停止した時だけ再生を復帰し、無効な文ではStateを変更しません。
  Future<void> seekToSentence(TranscriptSentence sentence) async {
    final startMs = sentence.startMs;
    final endMs = sentence.endMs;
    final before = state.position;
    final wasPlaying = state.isPlaying;
    final sourceReady =
        state.hasSource &&
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

  /// 音声サービスと表示Stateの再生速度を同期して更新します。
  ///
  /// [speed]はPlayerへ渡す再生倍率で、成功後にUI Stateへも反映します。
  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  /// 単題ループ、順次再生、全題ループの順にmodeを切り替えます。
  ///
  /// 音源未設定または読み込み中は何もせず、単題ループだけをNative Playerへ設定します。
  Future<void> cycleQuestionPlaybackMode() async {
    if (!state.hasSource || state.status == AudioPlayerStatus.loading) return;
    final next = switch (state.playbackMode) {
      QuestionPlaybackMode.repeatCurrent => QuestionPlaybackMode.sequential,
      QuestionPlaybackMode.sequential => QuestionPlaybackMode.repeatAll,
      QuestionPlaybackMode.repeatAll => QuestionPlaybackMode.repeatCurrent,
    };
    await _service.setQuestionLooping(
      next == QuestionPlaybackMode.repeatCurrent,
    );
    state = state.copyWith(playbackMode: next);
  }

  /// 現在の問題を先頭から再生し、1問だけの全題ループにも使用します。
  ///
  /// 音源未設定または読み込み中は何も行いません。
  Future<void> replayCurrentQuestion() async {
    if (!state.hasSource || state.status == AudioPlayerStatus.loading) return;
    await seek(Duration.zero);
    // completed時のplaying flagはPlatform実装ごとに異なるため、明示的に再生を要求します。
    await _service.play();
  }

  /// 問題切り替え用に旧音源の停止を開始し、速度と再生modeだけを表示用に維持します。
  ///
  /// 呼び出し元は完了を待たずにRouteを置換できます。次の[loadQuestion]が内部で
  /// stop完了を待つため、遅れて完了したstopが新音源を停止する競合を防ぎます。
  Future<void> beginQuestionChange() => _stop(preservePreferences: true);

  /// 再生を停止し、画面へ公開する State を初期状態へ戻します。
  Future<void> stop() => _stop(preservePreferences: false);

  /// 現在音源の停止を直列化します。
  ///
  /// [preservePreferences]が`true`なら速度と再生modeを保った空Stateへ更新します。`false`なら
  /// 停止完了後に完全な初期Stateへ戻します。既に停止中なら同じFutureを返します。
  Future<void> _stop({required bool preservePreferences}) {
    final existing = _pendingStopOperation;
    if (existing != null) return existing;

    final previous = state;
    final requestId = ++_sourceRequestId;
    _currentAudioLocation = null;
    if (preservePreferences) {
      // 問題切り替えだけはPlatformのstop完了を待たず、Route置換前に操作を無効化します。
      state = AudioPlayerState(
        speed: previous.speed,
        playbackMode: previous.playbackMode,
      );
    }

    late final Future<void> operation;
    operation = (() async {
      try {
        await _service.stop();
        // 通常の画面破棄ではunmount中の同期通知を避け、stop完了後に初期化します。
        if (!preservePreferences && requestId == _sourceRequestId) {
          state = const AudioPlayerState();
        }
      } catch (error) {
        if (requestId == _sourceRequestId) {
          state = state.copyWith(
            status: AudioPlayerStatus.error,
            errorMessage: '音声を停止できませんでした。\n$error',
          );
        }
      } finally {
        if (identical(_pendingStopOperation, operation)) {
          _pendingStopOperation = null;
        }
      }
    })();
    _pendingStopOperation = operation;
    return operation;
  }

  /// Debug buildで文seekの入力・出力を記録します。
  ///
  /// [sentence]、[before]、[after]、[wasPlaying]、[result]はseek判定の監査情報です。
  /// release buildでは何も出力しません。
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
      'audioSource=${_currentAudioLocation?.type.name}:'
      '${_currentAudioLocation?.path}, '
      'playingBefore=$wasPlaying, playingAfter=${state.isPlaying}',
    );
  }

  /// Playerの位置StreamをUI Stateと活性文へ反映します。
  ///
  /// [position]は音源先頭からの現在位置です。idle・loading・error中の遅延イベントは無視します。
  void _onPosition(Duration position) {
    // setAsset中は旧音源のposition eventが届く可能性があるため、新問題のStateへ反映しません。
    if (state.status == AudioPlayerStatus.idle ||
        state.status == AudioPlayerStatus.loading ||
        state.status == AudioPlayerStatus.error) {
      return;
    }
    final active = findActiveSentence(state.sentences, position);
    state = state.copyWith(
      position: position,
      activeSentenceId: active?.id,
      clearActiveSentence: active == null,
    );
  }

  /// Native音声エンジンの状態をアプリ用のAudioPlayerStatusへ変換します。
  ///
  /// [snapshot]のprocessingとplayingを組み合わせ、問題切り替えstop由来のidle通知は無視します。
  void _onEngineState(AudioEngineSnapshot snapshot) {
    // 問題切り替えのstop由来のidleは、新音源のloading表示へ変換しません。
    if (_pendingStopOperation != null &&
        snapshot.processing == AudioEngineProcessing.idle) {
      return;
    }
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
/// [sentences]の判定区間はstartMsを含みendMsを含みません。
///
/// [position]に該当する文を二分探索で返し、時間情報が欠ける場合や文間の空白では`null`を返します。
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
