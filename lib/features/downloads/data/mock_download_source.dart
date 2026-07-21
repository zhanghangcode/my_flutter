import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../practice/domain/practice_models.dart';
import '../domain/download_source.dart';

/// assets内の音声から試験単位のZIPを生成するMock Download用Source。
///
/// サーバーがまだ存在しない開発段階で、実際のダウンロード処理と同じInterfaceを使い、
/// Local Directoryへの保存・検証・再生確認を行うために使用します。
class MockDownloadSource implements DownloadSource {
  /// Bundle Assetから音声ZIPを生成するMock Sourceを生成します。
  ///
  /// [bundle]を指定するとテスト用AssetBundleを注入できます。`null`の場合はFlutterの
  /// [rootBundle]を使用します。
  MockDownloadSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// 音声bytesの取得に使用するAssetBundleです。
  final AssetBundle _bundle;

  @override
  Future<void> downloadArchive(
    ExamSummary summary,
    ExamResource resource,
    File destination, {
    required void Function(double progress) onProgress,
  }) async {
    final archive = Archive();
    onProgress(0);
    for (var index = 0; index < resource.questions.length; index++) {
      final question = resource.questions[index];
      final data = await _bundle.load(question.audioAssetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      archive.addFile(
        ArchiveFile.bytes(p.basename(question.audioAssetPath), bytes),
      );
      onProgress((index + 1) / resource.questions.length * 0.8);
    }
    final encoded = ZipEncoder().encodeBytes(archive);
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(encoded, flush: true);
    onProgress(1);
  }
}
