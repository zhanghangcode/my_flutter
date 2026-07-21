import 'dart:io';

import 'package:dio/dio.dart';

import '../../practice/domain/practice_models.dart';
import '../domain/download_source.dart';

/// Cloudflare R2の公開Custom Domainから試験単位のZIPを取得します。
class R2ZipDownloadSource implements DownloadSource {
  /// 大容量ファイルを端末へ直接保存するHTTP clientを注入して生成します。
  R2ZipDownloadSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 30),
              followRedirects: true,
            ),
          );

  /// 大容量ファイルを端末へ直接保存するHTTP clientです。
  final Dio _dio;

  /// 教材metadataに設定された公開ZIPのURLを検証して返します。
  Uri archiveUriFor(ExamSummary summary) {
    final url = summary.audioPackageUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
      throw const FormatException('音声パッケージURLの設定が正しくありません。');
    }
    return uri;
  }

  @override
  Future<void> downloadArchive(
    ExamSummary summary,
    ExamResource resource,
    File destination, {
    required void Function(double progress) onProgress,
  }) async {
    await destination.parent.create(recursive: true);
    onProgress(0);
    final response = await _dio.downloadUri(
      archiveUriFor(summary),
      destination.path,
      deleteOnError: false,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 ||
        statusCode >= 300 ||
        !await destination.exists() ||
        await destination.length() <= 0) {
      throw StateError('R2 ZIP download failed: HTTP $statusCode');
    }
    onProgress(1);
  }
}
