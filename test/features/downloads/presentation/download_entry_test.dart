import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/downloads/application/download_controller.dart';
import 'package:nihongo_listening/features/downloads/domain/download_repository.dart';
import 'package:nihongo_listening/features/downloads/domain/download_state.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/presentation/practice_list_page.dart';
import 'package:nihongo_listening/features/test/presentation/test_home_page.dart';

import '../../../helpers/practice_test_fakes.dart';

/// Practice/Test入口が同じDownload確認を利用することを確認します。
void main() {
  testWidgets('Practiceでキャンセル時は保存・遷移せず、成功時だけ1回遷移する', (tester) async {
    final repository = _EntryDownloadRepository();
    final router = GoRouter(
      initialLocation: '/practice',
      routes: [
        GoRoute(path: '/practice', builder: (_, _) => const PracticeListPage()),
        GoRoute(
          path: '/practice/:examId',
          builder: (_, _) => const Scaffold(body: Text('practice-target')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(
              _resource,
              audioDeliveryMode: AudioDeliveryMode.downloadRequired,
            ),
          ),
          downloadRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 同じカードを連続で押しても、Hookのローカル状態によりDialogは1つだけ開きます。
    await tester.tap(find.text(_summary.titleJa));
    await tester.tap(find.text(_summary.titleJa), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('音声データをダウンロードしますか？'), findsOneWidget);
    expect(
      find.text(
        '2026年7月の音声データを端末にダウンロードします。\n'
        'ダウンロード後はオフラインでも再生できます。',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();
    expect(repository.downloadCount, 0);
    expect(find.text('practice-target'), findsNothing);

    await tester.tap(find.text(_summary.titleJa));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ダウンロード'));
    await tester.pumpAndSettle();
    expect(repository.downloadCount, 1);
    expect(find.text('practice-target'), findsOneWidget);
  });

  testWidgets('TestでもDownload成功後だけSessionへ遷移する', (tester) async {
    final repository = _EntryDownloadRepository();
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, _) => const TestHomePage()),
        GoRoute(
          path: '/test/:examId/session',
          builder: (_, _) => const Scaffold(body: Text('test-target')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(
              _resource,
              audioDeliveryMode: AudioDeliveryMode.downloadRequired,
            ),
          ),
          downloadRepositoryProvider.overrideWithValue(repository),
          testResultsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_summary.titleJa));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ダウンロード'));
    await tester.pumpAndSettle();

    expect(repository.downloadCount, 1);
    expect(find.text('test-target'), findsOneWidget);
  });

  testWidgets('Download待機中にカードを破棄してもHookのStateを更新しない', (tester) async {
    final pendingDownload = Completer<DownloadInspection>();
    final repository = _EntryDownloadRepository(
      pendingDownload: pendingDownload,
    );
    final router = GoRouter(
      initialLocation: '/practice',
      routes: [
        GoRoute(path: '/practice', builder: (_, _) => const PracticeListPage()),
        GoRoute(
          path: '/practice/:examId',
          builder: (_, _) => const Scaffold(body: Text('practice-target')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(
              _resource,
              audioDeliveryMode: AudioDeliveryMode.downloadRequired,
            ),
          ),
          downloadRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_summary.titleJa));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ダウンロード'));
    await tester.pump();

    // 非同期処理の完了前にWidget treeを破棄する状況を再現します。
    await tester.pumpWidget(const SizedBox.shrink());
    pendingDownload.complete(_EntryDownloadRepository.inspection);
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

/// 初回は未保存、download後はLocal pathを返す入口テスト用Repository。
class _EntryDownloadRepository implements DownloadRepository {
  /// 完了を外部から制御する場合に[pendingDownload]を指定します。
  _EntryDownloadRepository({this.pendingDownload});

  /// Widget破棄前後の非同期完了を再現するための任意の待機処理です。
  final Completer<DownloadInspection>? pendingDownload;

  /// Downloadが完了済みかを保持します。
  bool downloaded = false;

  /// 実行されたDownload回数です。
  int downloadCount = 0;

  @override
  Future<DownloadInspection> download(
    ExamSummary summary,
    ExamResource resource, {
    required void Function(double progress) onProgress,
  }) async {
    downloadCount++;
    onProgress(0.5);
    final pending = pendingDownload;
    if (pending != null) {
      final result = await pending.future;
      downloaded = result.isDownloaded;
      onProgress(1);
      return result;
    }
    downloaded = true;
    onProgress(1);
    return inspection;
  }

  @override
  Future<DownloadInspection> inspect(
    ExamSummary summary,
    ExamResource resource,
  ) async => downloaded
      ? inspection
      : const DownloadInspection(status: DownloadStatus.notDownloaded);

  @override
  Future<String?> resolveLocalAudioPath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async => downloaded ? '/local/q1.mp3' : null;

  @override
  Future<String?> resolveLocalImagePath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async => null;

  @override
  Future<String?> resolveLocalOptionImagePath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
    AnswerOption option,
  ) async => null;

  /// 保存完了時に返す固定検査結果です。
  static const inspection = DownloadInspection(
    status: DownloadStatus.downloaded,
    localAudioPaths: {'q1': '/local/q1.mp3'},
    resourceVersion: 1,
  );
}

const _resource = ExamResource(
  schemaVersion: 2,
  id: 'exam-1',
  titleJa: '2026年7月・体験版',
  questions: [
    Question(
      id: 'q1',
      examId: 'exam-1',
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

const _summary = ExamSummary(
  id: 'exam-1',
  year: 2026,
  month: 7,
  titleJa: '2026年7月・体験版',
  audioQuality: '良い',
  questionCount: 1,
  resourcePath: 'unused.json',
  supportsTest: true,
  audioDeliveryMode: AudioDeliveryMode.downloadRequired,
);
