import 'dart:typed_data';

/// 取得元と保存名をquestionIdで結び付けた1音声分の要求。
class DownloadItem {
  /// 問題別音声の取得要求を生成します。
  const DownloadItem({
    required this.questionId,
    required this.sourcePath,
    required this.fileName,
  });

  /// 音声と問題を対応付ける一意なIDです。
  final String questionId;

  /// 現在のDownload Sourceが読み込む音声pathです。
  final String sourcePath;

  /// Local Directoryへ保存するquestionIdベースのファイル名です。
  final String fileName;
}

/// examに紐づく問題別音声のbytesを取得する取得元の抽象化。
///
/// Mock（Bundle Asset）と将来のHTTP（Dio）実装を同じInterfaceで扱うことで、
/// DownloadRepositoryはSourceの種類を意識せずに済みます。
abstract interface class DownloadSource {
  /// 指定した問題別音声のbytesを取得します。
  ///
  /// [item]のquestionIdは保存後の対応確認、sourcePathは実際の取得に使用します。
  Future<Uint8List> fetch(DownloadItem item);
}
