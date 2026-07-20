import 'package:flutter/services.dart';

import '../domain/download_source.dart';

/// assets内の音声をそのままbytesとして返すMock Download用のSource。
///
/// サーバーがまだ存在しない開発段階で、実際のダウンロード処理と同じInterfaceを使い、
/// Local Directoryへの保存・検証・再生確認を行うために使用します。
class MockDownloadSource implements DownloadSource {
  /// Bundle Assetから音声を取得するMock Sourceを生成します。
  ///
  /// [bundle]を指定するとテスト用AssetBundleを注入できます。`null`の場合はFlutterの
  /// [rootBundle]を使用します。
  MockDownloadSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// 音声bytesの取得に使用するAssetBundleです。
  final AssetBundle _bundle;

  @override
  /// [item]が参照するAsset bytesをそのまま返します。
  Future<Uint8List> fetch(DownloadItem item) async {
    final data = await _bundle.load(item.sourcePath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
