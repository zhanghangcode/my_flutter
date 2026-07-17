import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// just_audio の ProcessingState をアプリ内で扱うための抽象化。
enum AudioEngineProcessing { idle, loading, buffering, ready, completed }

/// 再生中フラグと音源処理状態を一つにまとめたスナップショット。
class AudioEngineSnapshot {
  const AudioEngineSnapshot({required this.playing, required this.processing});

  final bool playing;
  final AudioEngineProcessing processing;
}

/// 音声 Plugin の API を Controller から分離するサービス境界。
///
/// UI と Controller は just_audio の型へ依存せず、テスト時に別実装へ差し替えられます。
abstract interface class AudioPlaybackService {
  /// 現在の音声エンジンが再生中かを返します。
  bool get playing;

  /// 現在の再生位置を継続的に配信します。
  Stream<Duration> get positionStream;

  /// バッファ済み位置を継続的に配信します。
  Stream<Duration> get bufferedPositionStream;

  /// 音源から判定された総再生時間を配信します。
  Stream<Duration?> get durationStream;

  /// 再生・読み込み状態の変化を配信します。
  Stream<AudioEngineSnapshot> get stateStream;

  /// Asset 音源を読み込み、総再生時間を返します。
  Future<Duration> loadAsset(String assetPath);

  /// 読み込み済み音源を再生します。
  Future<void> play();

  /// 再生位置を維持したまま一時停止します。
  Future<void> pause();

  /// 現在の音源の再生を停止します。
  Future<void> stop();

  /// 指定位置へ再生ヘッドを移動します。
  Future<void> seek(Duration position);

  /// 再生速度を変更します。
  Future<void> setSpeed(double speed);

  /// 問題全体のループ再生を有効または無効にします。
  Future<void> setQuestionLooping(bool enabled);

  /// AudioPlayer が保持するネイティブリソースを解放します。
  Future<void> dispose();
}

/// just_audio と audio_session を利用する本番用 [AudioPlaybackService]。
class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService() : _player = AudioPlayer() {
    _sessionReady = _configureSession();
  }

  final AudioPlayer _player;
  late final Future<void> _sessionReady;

  @override
  bool get playing => _player.playing;

  Future<void> _configureSession() async {
    // 発話コンテンツ向け設定により、OS の音声フォーカスと割り込みへ対応します。
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
    // AudioSession の準備が完了してから音源を設定し、初回再生時の競合を避けます。
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

/// AudioPlaybackService の生成と破棄を Riverpod のライフサイクルで管理します。
final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  final service = JustAudioPlaybackService();
  ref.onDispose(service.dispose);
  return service;
});
