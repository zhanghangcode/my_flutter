import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/downloads/application/download_controller.dart';
import 'package:nihongo_listening/features/downloads/domain/download_repository.dart';
import 'package:nihongo_listening/features/downloads/domain/download_state.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

/// DownloadControllerの状態遷移と重複Future抑止を確認します。
void main() {
  test('連続Download要求を1回へまとめ、進捗とLocal pathを公開する', () async {
    final repository = _FakeDownloadRepository();
    final container = ProviderContainer(
      overrides: [downloadRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(downloadControllerProvider.notifier);

    final first = controller.download(_summary, _resource);
    final second = controller.download(_summary, _resource);
    expect(repository.downloadCount, 1);
    expect(
      container.read(downloadControllerProvider)['exam']?.status,
      DownloadStatus.downloading,
    );

    repository.progress?.call(1.5);
    expect(container.read(downloadControllerProvider)['exam']?.progress, 1);
    repository.completer.complete(
      const DownloadInspection(
        status: DownloadStatus.downloaded,
        localAudioPaths: {'q1': '/local/q1.mp3'},
        resourceVersion: 1,
      ),
    );

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(repository.downloadCount, 1);
    expect(
      container.read(downloadControllerProvider)['exam']?.localAudioPaths,
      {'q1': '/local/q1.mp3'},
    );
  });

  test('Provider破棄後に進捗・完了が届いてもState更新例外を発生させない', () async {
    final repository = _FakeDownloadRepository();
    final container = ProviderContainer(
      overrides: [downloadRepositoryProvider.overrideWithValue(repository)],
    );
    final operation = container
        .read(downloadControllerProvider.notifier)
        .download(_summary, _resource);

    container.dispose();
    repository.progress?.call(0.5);
    repository.completer.complete(
      const DownloadInspection(
        status: DownloadStatus.downloaded,
        localAudioPaths: {'q1': '/local/q1.mp3'},
        resourceVersion: 1,
      ),
    );

    await expectLater(operation, completion(isTrue));
  });
}

/// Controllerの非同期完了をテストから制御するDownload Repository。
class _FakeDownloadRepository implements DownloadRepository {
  /// Download完了を制御するCompleterです。
  final completer = Completer<DownloadInspection>();

  /// Repositoryへ到達したDownload回数です。
  int downloadCount = 0;

  /// Repositoryへ渡された進捗通知です。
  void Function(double)? progress;

  @override
  Future<DownloadInspection> download(
    ExamSummary summary,
    ExamResource resource, {
    required void Function(double progress) onProgress,
  }) {
    downloadCount++;
    progress = onProgress;
    return completer.future;
  }

  @override
  Future<DownloadInspection> inspect(
    ExamSummary summary,
    ExamResource resource,
  ) async => const DownloadInspection(status: DownloadStatus.notDownloaded);

  @override
  Future<String?> resolveLocalAudioPath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async => null;
}

const _summary = ExamSummary(
  id: 'exam',
  year: 2026,
  month: 7,
  titleJa: '試験',
  audioQuality: '良い',
  questionCount: 1,
  resourcePath: 'exam.json',
  supportsTest: true,
  audioDeliveryMode: AudioDeliveryMode.downloadRequired,
);

const _resource = ExamResource(
  schemaVersion: 2,
  id: 'exam',
  titleJa: '試験',
  questions: [
    Question(
      id: 'q1',
      examId: 'exam',
      section: 1,
      number: 1,
      type: 'demo',
      promptJa: '問題',
      options: [],
      audioAssetPath: 'assets/audio/q1.mp3',
      sentences: [],
    ),
  ],
);
