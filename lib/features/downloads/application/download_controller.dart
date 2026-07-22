import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../practice/domain/practice_models.dart';
import '../data/local_download_repository.dart';
import '../data/r2_zip_download_source.dart';
import '../domain/download_repository.dart';
import '../domain/download_source.dart';
import '../domain/download_state.dart';

/// R2 Custom Domainから試験単位ZIPを取得するSourceを提供するProvider。
///
/// `AUDIO_PACKAGE_BASE_URL`は`--dart-define`で環境別に差し替えられます。
final downloadSourceProvider = Provider<DownloadSource>(
  (ref) => R2ZipDownloadSource(),
);

/// DownloadControllerと音源Resolverが共有するRepositoryを提供するProvider。
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => LocalDownloadRepository(
    ref.watch(downloadSourceProvider),
    ref.watch(databaseProvider),
  ),
);

/// ダウンロードStateと操作APIをUIへ公開するProvider。
final downloadControllerProvider =
    NotifierProvider<DownloadController, Map<String, ExamDownloadState>>(
      DownloadController.new,
    );

/// catalog metadataと試験内容を読み込み、必要な教材だけLocal Fileを確認します。
///
/// bundled教材はFile I/Oを行わず`true`を返し、Practice/Testの両入口で同じ判定を共有します。
final examDownloadCheckProvider = FutureProvider.family<bool, String>((
  ref,
  examId,
) async {
  final summaries = await ref.watch(examCatalogProvider.future);
  final summary = summaries.singleWhere((item) => item.id == examId);
  if (summary.audioDeliveryMode == AudioDeliveryMode.bundled) return true;
  final resource = await ref.watch(examResourceProvider(examId).future);
  return ref
      .read(downloadControllerProvider.notifier)
      .ensureStatusChecked(summary, resource);
});

/// 試験ごとの音声ダウンロード状態と非同期操作を直列化するNotifier。
///
/// examId単位で進行中Futureを共有するため、複数画面や連続タップから同じ確認・保存が
/// 要求されてもFile I/Oを重複実行しません。
class DownloadController extends Notifier<Map<String, ExamDownloadState>> {
  /// Local Manifestと実ファイルを管理するRepositoryです。
  late DownloadRepository _repository;

  /// examIdごとに進行中の実ファイル確認を保持します。
  final Map<String, Future<bool>> _checkOperations = {};

  /// examIdごとに進行中のダウンロードを保持します。
  final Map<String, Future<bool>> _downloadOperations = {};

  /// 古い確認結果が新しいDownload Stateを上書きしないための世代番号です。
  final Map<String, int> _operationVersions = {};

  @override
  /// Repository依存をProviderから取得し、未確認の空Stateを返します。
  Map<String, ExamDownloadState> build() {
    _repository = ref.watch(downloadRepositoryProvider);
    return const {};
  }

  /// 指定examIdのStateを返し、未確認時は未ダウンロードとして扱います。
  ExamDownloadState stateFor(String examId) =>
      state[examId] ?? const ExamDownloadState.notDownloaded();

  /// Drift Manifestと実ファイルを照合し、再生可能かを返します。
  ///
  /// 同じexamIdの確認が進行中なら同じFutureを返し、Download開始後に完了した古い結果は
  /// Stateへ反映しません。
  Future<bool> ensureStatusChecked(ExamSummary summary, ExamResource resource) {
    if (summary.audioDeliveryMode == AudioDeliveryMode.bundled) {
      return Future<bool>.value(true);
    }
    final downloading = _downloadOperations[summary.id];
    if (downloading != null) return downloading;
    final existing = _checkOperations[summary.id];
    if (existing != null) return existing;

    final version = _operationVersions[summary.id] ?? 0;
    late final Future<bool> operation;
    operation = (() async {
      try {
        final result = await _repository.inspect(summary, resource);
        if (ref.mounted && (_operationVersions[summary.id] ?? 0) == version) {
          state = {...state, summary.id: _stateFromInspection(result)};
        }
        return result.isDownloaded;
      } finally {
        if (identical(_checkOperations[summary.id], operation)) {
          _checkOperations.remove(summary.id);
        }
      }
    })();
    _checkOperations[summary.id] = operation;
    return operation;
  }

  /// 試験音声を保存し、進捗と検証済みLocal pathをStateへ反映します。
  ///
  /// 同じexamIdの保存要求は進行中Futureへ合流します。失敗時は利用者向けの日本語だけを
  /// Stateへ公開し、詳細なFile I/O情報はRepository内のDebug logに限定します。
  Future<bool> download(ExamSummary summary, ExamResource resource) {
    final existing = _downloadOperations[summary.id];
    if (existing != null) return existing;

    final version = (_operationVersions[summary.id] ?? 0) + 1;
    _operationVersions[summary.id] = version;
    state = {
      ...state,
      summary.id: const ExamDownloadState.downloading(progress: 0),
    };

    late final Future<bool> operation;
    operation = (() async {
      try {
        final result = await _repository.download(
          summary,
          resource,
          onProgress: (progress) {
            if (!ref.mounted ||
                (_operationVersions[summary.id] ?? 0) != version) {
              return;
            }
            state = {
              ...state,
              summary.id: ExamDownloadState.downloading(
                progress: progress.clamp(0.0, 1.0).toDouble(),
              ),
            };
          },
        );
        if (ref.mounted && (_operationVersions[summary.id] ?? 0) == version) {
          state = {...state, summary.id: _stateFromInspection(result)};
        }
        return result.isDownloaded;
      } catch (_) {
        if (ref.mounted && (_operationVersions[summary.id] ?? 0) == version) {
          state = {
            ...state,
            summary.id: const ExamDownloadState.failed(
              '音声データのダウンロードに失敗しました。もう一度お試しください。',
            ),
          };
        }
        rethrow;
      } finally {
        if (identical(_downloadOperations[summary.id], operation)) {
          _downloadOperations.remove(summary.id);
        }
      }
    })();
    _downloadOperations[summary.id] = operation;
    return operation;
  }

  /// Repositoryの検査結果を画面用のimmutable Stateへ変換します。
  ExamDownloadState _stateFromInspection(DownloadInspection inspection) {
    return switch (inspection.status) {
      DownloadStatus.downloaded => ExamDownloadState.downloaded(
        localAudioPaths: inspection.localAudioPaths,
        localImagePaths: inspection.localImagePaths,
        resourceVersion: inspection.resourceVersion,
      ),
      DownloadStatus.failed => const ExamDownloadState.failed(
        '前回のダウンロードに失敗しました。もう一度お試しください。',
      ),
      DownloadStatus.notDownloaded ||
      DownloadStatus.downloading => const ExamDownloadState.notDownloaded(),
    };
  }
}
