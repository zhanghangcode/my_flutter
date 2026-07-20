import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/audio_source_location.dart';

/// just_audio のProcessingStateをアプリ内で扱うための抽象化。
enum AudioEngineProcessing {
  /// 音源が設定されていない停止状態です。
  idle,

  /// 音源を読み込んでいる状態です。
  loading,

  /// 再生に必要なデータをバッファリングしている状態です。
  buffering,

  /// 再生またはseekを受け付けられる準備完了状態です。
  ready,

  /// 音源の末尾まで再生した状態です。
  completed,
}

/// 再生中フラグと音源処理状態を一つにまとめたスナップショット。
class AudioEngineSnapshot {
  /// 音声エンジンの状態スナップショットを生成します。
  ///
  /// [playing]は実際に音声出力中か、[processing]は音源の準備状態です。
  const AudioEngineSnapshot({required this.playing, required this.processing});

  /// 音声エンジンが現在出力中かを示します。
  final bool playing;

  /// 音源の読み込み・再生完了などの処理状態です。
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

  /// AssetまたはLocal File音源を読み込み、総再生時間を返します。
  Future<Duration> loadSource(AudioSourceLocation source);

  /// 読み込み済み音源を再生します。
  ///
  /// 返却されるFutureは再生開始要求の完了を表し、再生完了までは待ちません。
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
  /// just_audioを使用する本番用サービスを生成します。
  ///
  /// AudioPlayerを1つだけ生成し、AudioSession設定は非同期で開始します。
  JustAudioPlaybackService() : _player = AudioPlayer() {
    _sessionReady = _configureSession();
  }

  /// すべての再生操作を委譲する単一のjust_audio AudioPlayer。
  final AudioPlayer _player;

  /// AudioSession設定の完了を待つFutureです。
  late final Future<void> _sessionReady;

  /// just_audio が再生中と判断しているかを返します。
  @override
  bool get playing => _player.playing;

  /// 発話教材向けのAudioSessionを非同期で設定します。
  Future<void> _configureSession() async {
    // 発話コンテンツ向け設定により、OS の音声フォーカスと割り込みへ対応します。
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  /// just_audio が配信する現在の再生位置をそのまま公開します。
  @override
  Stream<Duration> get positionStream => _player.positionStream;

  /// just_audio が配信するバッファ済み位置をそのまま公開します。
  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  /// just_audio が判定した総再生時間を公開します。
  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  /// just_audio の PlayerState をアプリ固有の状態へ変換して配信します。
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

  /// 指定されたAssetまたはLocal Fileを読み込み、判定された再生時間を返します。
  ///
  /// [source]の保存場所に対応するAudioSourceを選び、以前の音源を置き換えます。
  @override
  Future<Duration> loadSource(AudioSourceLocation source) async {
    // AudioSession の準備が完了してから音源を設定し、初回再生時の競合を避けます。
    await _sessionReady;
    final audioSource = switch (source.type) {
      AudioSourceLocationType.asset => AudioSource.asset(source.path),
      AudioSourceLocationType.file => AudioSource.file(source.path),
    };
    final duration = await _player.setAudioSource(audioSource);
    return duration ?? Duration.zero;
  }

  /// 読み込み済み音源の再生を開始または再開します。
  ///
  /// just_audioのplay()が返すFutureは再生開始ではなく、再生完了・一時停止・停止時に
  /// 完了する仕様のため、そのままawaitすると呼び出し元が再生完了までブロックされます。
  /// ここでは開始要求だけを行い、完了を待たずに即座に返します。
  @override
  Future<void> play() {
    unawaited(_player.play());
    return Future<void>.value();
  }

  /// 現在位置を保持したまま再生を一時停止します。
  @override
  Future<void> pause() => _player.pause();

  /// 現在の音源を停止します。
  @override
  Future<void> stop() => _player.stop();

  /// 再生ヘッドを[position]へ移動します。
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// 再生速度を[speed]倍へ変更します。
  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  /// 問題全体のループ再生を[enabled]に応じて設定します。
  @override
  Future<void> setQuestionLooping(bool enabled) =>
      _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);

  /// Native AudioPlayerを破棄してリソースを解放します。
  @override
  Future<void> dispose() => _player.dispose();
}

/// AudioPlaybackService の生成と破棄を Riverpod のライフサイクルで管理します。
///
/// Provider の破棄時に Native AudioPlayer も解放するため、画面側で Plugin の
/// dispose を直接呼ぶ必要がありません。
final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  final service = JustAudioPlaybackService();
  ref.onDispose(service.dispose);
  return service;
});
