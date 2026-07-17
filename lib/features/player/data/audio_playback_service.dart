import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum AudioEngineProcessing { idle, loading, buffering, ready, completed }

class AudioEngineSnapshot {
  const AudioEngineSnapshot({required this.playing, required this.processing});

  final bool playing;
  final AudioEngineProcessing processing;
}

abstract interface class AudioPlaybackService {
  Stream<Duration> get positionStream;
  Stream<Duration> get bufferedPositionStream;
  Stream<Duration?> get durationStream;
  Stream<AudioEngineSnapshot> get stateStream;

  Future<Duration> loadAsset(String assetPath);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setQuestionLooping(bool enabled);
  Future<void> dispose();
}

class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService() : _player = AudioPlayer() {
    _sessionReady = _configureSession();
  }

  final AudioPlayer _player;
  late final Future<void> _sessionReady;

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<AudioEngineSnapshot> get stateStream => _player.playerStateStream.map(
    (snapshot) => AudioEngineSnapshot(
      playing: snapshot.playing,
      processing: switch (snapshot.processingState) {
        ProcessingState.idle => AudioEngineProcessing.idle,
        ProcessingState.loading => AudioEngineProcessing.loading,
        ProcessingState.buffering => AudioEngineProcessing.buffering,
        ProcessingState.ready => AudioEngineProcessing.ready,
        ProcessingState.completed => AudioEngineProcessing.completed,
      },
    ),
  );

  @override
  Future<Duration> loadAsset(String assetPath) async {
    await _sessionReady;
    final duration = await _player.setAudioSource(AudioSource.asset(assetPath));
    return duration ?? Duration.zero;
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setQuestionLooping(bool enabled) =>
      _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);

  @override
  Future<void> dispose() => _player.dispose();
}

final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  final service = JustAudioPlaybackService();
  ref.onDispose(service.dispose);
  return service;
});
