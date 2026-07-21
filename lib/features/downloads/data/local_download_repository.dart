import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../database/app_database.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/download_repository.dart';
import '../domain/download_source.dart';
import '../domain/download_state.dart';

/// Download Sourceから取得したZIPを展開・検証し、Drift Manifestと照合するRepository。
///
/// 保存済みflagだけではなく、resource version、ファイル数、実在、非0-byte、`.part`の
/// 不在を毎回確認します。検証に失敗した音声を再生可能として返すことはありません。
class LocalDownloadRepository implements DownloadRepository {
  /// 音声取得元、Manifest DB、保存先Directoryの解決方法を注入して生成します。
  LocalDownloadRepository(
    this._source,
    this._database, {
    Future<Directory> Function()? resolveBaseDirectory,
  }) : _resolveBaseDirectory =
           resolveBaseDirectory ?? getApplicationSupportDirectory;

  /// 問題別音声bytesの取得元です。
  final DownloadSource _source;

  /// 音声のLocal Manifestを永続化するDrift DBです。
  final AppDatabase _database;

  /// Application Support Directoryまたはテスト用Directoryを返す関数です。
  final Future<Directory> Function() _resolveBaseDirectory;

  /// Download対象として許可する試験・問題IDの形式です。
  static final RegExp _safeId = RegExp(r'^[A-Za-z0-9_-]+$');

  @override
  Future<DownloadInspection> inspect(
    ExamSummary summary,
    ExamResource resource,
  ) async {
    if (summary.audioDeliveryMode != AudioDeliveryMode.downloadRequired) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }
    if (summary.id != resource.id ||
        !_safeId.hasMatch(summary.id) ||
        summary.audioResourceVersion <= 0 ||
        resource.questions.length != summary.questionCount) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }
    final questionIds = <String>{};
    if (resource.questions.any(
      (question) =>
          !_safeId.hasMatch(question.id) ||
          !questionIds.add(question.id) ||
          p.extension(question.audioAssetPath).isEmpty,
    )) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }
    final record = await (_database.select(
      _database.examDownloads,
    )..where((row) => row.examId.equals(summary.id))).getSingleOrNull();
    if (record == null) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }
    if (record.status == DownloadStatus.failed.name) {
      return DownloadInspection(
        status: DownloadStatus.failed,
        resourceVersion: record.resourceVersion,
      );
    }
    if (record.status != DownloadStatus.downloaded.name ||
        record.downloadedAtUtc == null ||
        record.localDirectory != _relativeAudioDirectory(summary.id) ||
        record.resourceVersion != summary.audioResourceVersion ||
        record.audioFileCount != resource.questions.length) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }

    final paths = await _verifyAudioDirectory(summary, resource);
    if (paths == null) {
      return const DownloadInspection(status: DownloadStatus.notDownloaded);
    }
    return DownloadInspection(
      status: DownloadStatus.downloaded,
      localAudioPaths: paths,
      resourceVersion: record.resourceVersion,
    );
  }

  @override
  Future<DownloadInspection> download(
    ExamSummary summary,
    ExamResource resource, {
    required void Function(double progress) onProgress,
  }) async {
    _validateRequest(summary, resource);
    final examDirectory = await _examDirectory(summary.id);
    final audioDirectory = await _audioDirectory(summary.id);
    final archiveFile = File(
      p.join(examDirectory.path, '${summary.id}.part.zip'),
    );
    final extractedDirectory = Directory(
      p.join(examDirectory.path, '.extracted'),
    );
    try {
      // 以前の失敗・version違いを混在させず、試験単位で常に作り直します。
      if (await examDirectory.exists()) {
        await examDirectory.delete(recursive: true);
      }
      await examDirectory.create(recursive: true);
      onProgress(0);

      final items = _buildItems(resource);
      await _source.downloadArchive(
        summary,
        resource,
        archiveFile,
        onProgress: (progress) {
          // 解凍・照合・原子的保存用に最後の10%を確保します。
          onProgress(progress.clamp(0.0, 1.0).toDouble() * 0.9);
        },
      );
      if (!await archiveFile.exists() || await archiveFile.length() <= 0) {
        throw StateError('0-byte archive');
      }

      await extractedDirectory.create(recursive: true);
      await extractFileToDisk(archiveFile.path, extractedDirectory.path);
      final extractedEntities = await extractedDirectory
          .list(recursive: true, followLinks: false)
          .toList();
      if (extractedEntities.whereType<Link>().isNotEmpty) {
        throw StateError('symbolic links are not allowed');
      }
      final extractedFiles = extractedEntities.whereType<File>().toList();
      await audioDirectory.create(recursive: true);

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        final matches = extractedFiles
            .where(
              (file) => p.basename(file.path) == p.basename(item.sourcePath),
            )
            .toList();
        if (matches.length != 1 || await matches.single.length() <= 0) {
          throw StateError('missing or duplicate audio: ${item.questionId}');
        }

        final target = File(p.join(audioDirectory.path, item.fileName));
        final partial = File('${target.path}.part');
        await matches.single.copy(partial.path);
        final sourceBytes = await matches.single.length();
        final writtenBytes = await partial.length();
        if (writtenBytes <= 0 || writtenBytes != sourceBytes) {
          throw StateError('incomplete file: ${item.questionId}');
        }
        if (await target.exists()) await target.delete();
        await partial.rename(target.path);
        if (!await target.exists() || await target.length() != sourceBytes) {
          throw StateError('rename verification failed: ${item.questionId}');
        }
        onProgress(0.9 + ((index + 1) / items.length * 0.1));
      }

      await _deleteIfExists(archiveFile);
      await _deleteDirectoryIfExists(extractedDirectory);

      final paths = await _verifyAudioDirectory(summary, resource);
      if (paths == null) {
        throw StateError('download directory verification failed');
      }
      await _saveDownloadedManifest(summary, resource.questions.length);
      final verified = await inspect(summary, resource);
      if (!verified.isDownloaded) {
        throw StateError('manifest verification failed');
      }
      return verified;
    } catch (error, stackTrace) {
      // 部分ファイルを利用可能にしないため、試験Directoryごと確実に破棄します。
      if (await examDirectory.exists()) {
        await examDirectory.delete(recursive: true);
      }
      try {
        await _saveFailedManifest(summary);
      } catch (manifestError, manifestStackTrace) {
        debugPrint(
          'Failed to save download failure manifest: '
          'examId=${summary.id}, error=$manifestError\n$manifestStackTrace',
        );
      }
      debugPrint(
        'Exam audio download failed: examId=${summary.id}, error=$error\n$stackTrace',
      );
      throw const ExamDownloadException('音声データのダウンロードに失敗しました。もう一度お試しください。');
    }
  }

  @override
  Future<String?> resolveLocalAudioPath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async {
    if (question.examId != summary.id ||
        !resource.questions.any((item) => item.id == question.id)) {
      return null;
    }
    final inspection = await inspect(summary, resource);
    return inspection.isDownloaded
        ? inspection.localAudioPaths[question.id]
        : null;
  }

  /// Download対象のmetadataと試験内容が安全に対応しているかを確認します。
  void _validateRequest(ExamSummary summary, ExamResource resource) {
    if (summary.audioDeliveryMode != AudioDeliveryMode.downloadRequired) {
      throw const ExamDownloadException('この教材はダウンロード対象ではありません。');
    }
    if (summary.id != resource.id ||
        !_safeId.hasMatch(summary.id) ||
        summary.audioResourceVersion <= 0 ||
        resource.questions.isEmpty ||
        resource.questions.length != summary.questionCount) {
      throw const ExamDownloadException('音声データの情報が正しくありません。');
    }
    _buildItems(resource);
  }

  /// questionIdと元音声の拡張子から、安全なLocal Manifest項目を生成します。
  List<_ExpectedAudioFile> _buildItems(ExamResource resource) {
    final questionIds = <String>{};
    return [
      for (final question in resource.questions)
        if (_safeId.hasMatch(question.id) &&
            questionIds.add(question.id) &&
            p.extension(question.audioAssetPath).isNotEmpty)
          _ExpectedAudioFile(
            questionId: question.id,
            sourcePath: question.audioAssetPath,
            fileName:
                '${question.id}${p.extension(question.audioAssetPath).toLowerCase()}',
          )
        else
          throw const ExamDownloadException('問題別音声の情報が正しくありません。'),
    ];
  }

  /// Directory内の正式ファイル、サイズ、`.part`不在を確認してpath mapを返します。
  Future<Map<String, String>?> _verifyAudioDirectory(
    ExamSummary summary,
    ExamResource resource,
  ) async {
    final directory = await _audioDirectory(summary.id);
    if (!await directory.exists()) return null;
    final entities = await directory.list(followLinks: false).toList();
    if (entities.any((entity) => entity.path.endsWith('.part')) ||
        entities.length != resource.questions.length ||
        entities.whereType<File>().length != resource.questions.length) {
      return null;
    }

    final paths = <String, String>{};
    for (final item in _buildItems(resource)) {
      final file = File(p.join(directory.path, item.fileName));
      if (!await file.exists() || await file.length() <= 0) return null;
      paths[item.questionId] = file.path;
    }
    return Map.unmodifiable(paths);
  }

  /// 検証完了済みのLocal ManifestをDriftへupsertします。
  Future<void> _saveDownloadedManifest(
    ExamSummary summary,
    int audioFileCount,
  ) => _database
      .into(_database.examDownloads)
      .insertOnConflictUpdate(
        ExamDownloadsCompanion.insert(
          examId: summary.id,
          status: DownloadStatus.downloaded.name,
          downloadedAtUtc: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
          localDirectory: Value(_relativeAudioDirectory(summary.id)),
          resourceVersion: summary.audioResourceVersion,
          audioFileCount: audioFileCount,
        ),
      );

  /// 失敗状態を保存し、次回起動後も一覧で再試行可能な状態を復元します。
  Future<void> _saveFailedManifest(ExamSummary summary) => _database
      .into(_database.examDownloads)
      .insertOnConflictUpdate(
        ExamDownloadsCompanion.insert(
          examId: summary.id,
          status: DownloadStatus.failed.name,
          resourceVersion: summary.audioResourceVersion,
          audioFileCount: 0,
        ),
      );

  /// Application Support Directoryを基準とする音声Directoryの相対pathを返します。
  String _relativeAudioDirectory(String examId) =>
      p.join('downloads', 'exams', examId, 'audio');

  /// 試験全体の保存Directoryを返します。
  Future<Directory> _examDirectory(String examId) async {
    final base = await _resolveBaseDirectory();
    return Directory(p.join(base.path, 'downloads', 'exams', examId));
  }

  /// 問題別音声ファイルを保存するDirectoryを返します。
  Future<Directory> _audioDirectory(String examId) async {
    final base = await _resolveBaseDirectory();
    return Directory(p.join(base.path, _relativeAudioDirectory(examId)));
  }

  /// 成功後の一時ZIPを削除します。削除失敗は検証済み音声を無効にしません。
  Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (error, stackTrace) {
      debugPrint('Failed to clean archive: $error\n$stackTrace');
    }
  }

  /// 成功後の展開用Directoryを削除します。
  Future<void> _deleteDirectoryIfExists(Directory directory) async {
    try {
      if (await directory.exists()) await directory.delete(recursive: true);
    } catch (error, stackTrace) {
      debugPrint('Failed to clean extracted files: $error\n$stackTrace');
    }
  }
}

/// ZIP内の元ファイル名と検証後のLocalファイル名を対応付けます。
class _ExpectedAudioFile {
  const _ExpectedAudioFile({
    required this.questionId,
    required this.sourcePath,
    required this.fileName,
  });

  final String questionId;
  final String sourcePath;
  final String fileName;
}
