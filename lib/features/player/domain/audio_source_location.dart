/// just_audioへ渡す音源の保存場所を表します。
enum AudioSourceLocationType {
  /// Flutter Bundleに同梱したAssetです。
  asset,

  /// Application Support Directoryへ保存して検証したLocal Fileです。
  file,
}

/// 音源pathと、そのpathをAsset/Fileのどちらとして扱うかを保持するValue Object。
class AudioSourceLocation {
  /// Bundle Assetの音源を生成します。
  const AudioSourceLocation.asset(this.path)
    : type = AudioSourceLocationType.asset;

  /// 端末内Local Fileの音源を生成します。
  const AudioSourceLocation.file(this.path)
    : type = AudioSourceLocationType.file;

  /// just_audioへ設定するpathです。
  final String path;

  /// pathの保存場所です。
  final AudioSourceLocationType type;

  /// Asset音源の場合に`true`を返します。
  bool get isAsset => type == AudioSourceLocationType.asset;

  /// Local File音源の場合に`true`を返します。
  bool get isFile => type == AudioSourceLocationType.file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSourceLocation && other.type == type && other.path == path;

  @override
  int get hashCode => Object.hash(type, path);
}
