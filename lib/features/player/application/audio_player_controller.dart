import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../practice/domain/practice_models.dart';
import '../data/audio_playback_service.dart';

enum AudioPlayerStatus {
  idle,
  loading,
  ready,
  playing,
  paused,
  completed,
  error,
}

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

  bool get hasSource => questionId != null;
  bool get isPlaying => status == AudioPlayerStatus.playing;

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

class AudioPlayerController extends Notifier<AudioPlayerState> {
  late final AudioPlaybackService _service;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _loopSeekInProgress = false;
  String? _sentenceLoopTargetId;

  @override
  AudioPlayerState build() {
    _service = ref.watch(audioPlaybackServiceProvider);
    _subscriptions
      ..add(_service.positionStream.listen(_onPosition))
      ..add(
        _service.bufferedPositionStream.listen(
          (position) => state = state.copyWith(bufferedPosition: position),
        ),
      )
      ..add(
        _service.durationStream.listen((duration) {
          if (duration != null) state = state.copyWith(duration: duration);
        }),
      )
      ..add(_service.stateStream.listen(_onEngineState));
    ref.onDispose(() {
      for (final subscription in _subscriptions) {
        unawaited(subscription.cancel());
      }
    });
    return const AudioPlayerState();
  }

  Future<void> loadQuestion(
    Question question, {
    double speed = 1,
    Duration restorePosition = Duration.zero,
  }) async {
    if (state.questionId == question.id &&
        state.status != AudioPlayerStatus.error) {
      return;
    }
    state = AudioPlayerState(
      status: AudioPlayerStatus.loading,
      questionId: question.id,
      sentences: question.sentences,
      speed: speed,
    );
    _sentenceLoopTargetId = null;
    try {
      await _service.setQuestionLooping(false);
      final duration = await _service.loadAsset(question.audioAssetPath);
      await _service.setSpeed(speed);
      final safePosition = restorePosition < duration
          ? restorePosition
          : Duration.zero;
      if (safePosition > Duration.zero) await _service.seek(safePosition);
      state = state.copyWith(
        status: AudioPlayerStatus.ready,
        duration: duration,
        position: safePosition,
        activeSentenceId: findActiveSentence(
          question.sentences,
          safePosition,
        )?.id,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: '音声を読み込めませんでした。\n$error',
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (!state.hasSource || state.status == AudioPlayerStatus.loading) return;
    try {
      if (state.isPlaying) {
        await _service.pause();
      } else {
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

  Future<void> seek(Duration position) async {
    if (!state.hasSource) return;
    final max = state.duration;
    final safe = position < Duration.zero
        ? Duration.zero
        : position > max
        ? max
        : position;
    await _service.seek(safe);
    _onPosition(safe);
  }

  Future<void> seekToSentence(TranscriptSentence sentence) =>
      seek(Duration(milliseconds: sentence.startMs));

  Future<void> previousSentence() async {
    final index = _activeSentenceIndex();
    if (state.sentences.isEmpty) return;
    final target = index <= 0 ? 0 : index - 1;
    await seekToSentence(state.sentences[target]);
  }

  Future<void> nextSentence() async {
    final index = _activeSentenceIndex();
    if (state.sentences.isEmpty) return;
    final target = index < 0
        ? 0
        : (index + 1).clamp(0, state.sentences.length - 1);
    await seekToSentence(state.sentences[target]);
  }

  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  Future<void> cycleRepeatMode() async {
    final next = switch (state.repeatMode) {
      RepeatMode.none => RepeatMode.sentence,
      RepeatMode.sentence => RepeatMode.question,
      RepeatMode.question => RepeatMode.none,
    };
    await _service.setQuestionLooping(next == RepeatMode.question);
    _sentenceLoopTargetId = next == RepeatMode.sentence
        ? state.activeSentenceId
        : null;
    state = state.copyWith(repeatMode: next);
  }

  Future<void> stop() async {
    await _service.stop();
    _sentenceLoopTargetId = null;
    state = const AudioPlayerState();
  }

  void _onPosition(Duration position) {
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
    if (state.repeatMode == RepeatMode.sentence &&
        loopTarget != null &&
        position.inMilliseconds >= loopTarget.endMs &&
        position.inMilliseconds <= loopTarget.endMs + 1000 &&
        !_loopSeekInProgress) {
      _loopSeekInProgress = true;
      unawaited(
        _service
            .seek(Duration(milliseconds: loopTarget.startMs))
            .whenComplete(() => _loopSeekInProgress = false),
      );
    }
  }

  void _onEngineState(AudioEngineSnapshot snapshot) {
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

  int _activeSentenceIndex() {
    if (state.activeSentenceId == null) return -1;
    return state.sentences.indexWhere(
      (sentence) => sentence.id == state.activeSentenceId,
    );
  }
}

TranscriptSentence? findActiveSentence(
  List<TranscriptSentence> sentences,
  Duration position,
) {
  var low = 0;
  var high = sentences.length - 1;
  final milliseconds = position.inMilliseconds;
  while (low <= high) {
    final middle = low + ((high - low) >> 1);
    final sentence = sentences[middle];
    if (milliseconds < sentence.startMs) {
      high = middle - 1;
    } else if (milliseconds >= sentence.endMs) {
      low = middle + 1;
    } else {
      return sentence;
    }
  }
  return null;
}

final audioPlayerControllerProvider =
    NotifierProvider<AudioPlayerController, AudioPlayerState>(
      AudioPlayerController.new,
    );
