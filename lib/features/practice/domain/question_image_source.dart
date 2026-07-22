/// 問題図版の表示に使うpathを、Asset/Fileのどちらとして扱うかを表します。
enum QuestionImageSourceType {
  /// Flutter Bundleに同梱したAssetです。
  asset,

  /// Application Support Directoryへ保存して検証したLocal Fileです。
  file,
}

/// 問題図版のpathと、そのpathをAsset/Fileのどちらとして扱うかを保持するValue Object。
class QuestionImageSource {
  /// Bundle Assetの図版を生成します。
  const QuestionImageSource.asset(this.path)
    : type = QuestionImageSourceType.asset;

  /// 端末内Local Fileの図版を生成します。
  const QuestionImageSource.file(this.path)
    : type = QuestionImageSourceType.file;

  /// `Image.asset`または`Image.file`へ設定するpathです。
  final String path;

  /// pathの保存場所です。
  final QuestionImageSourceType type;

  /// Asset図版の場合に`true`を返します。
  bool get isAsset => type == QuestionImageSourceType.asset;

  /// Local File図版の場合に`true`を返します。
  bool get isFile => type == QuestionImageSourceType.file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionImageSource && other.type == type && other.path == path;

  @override
  int get hashCode => Object.hash(type, path);
}
