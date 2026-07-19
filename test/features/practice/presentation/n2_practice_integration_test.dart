import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/practice/application/practice_detail_controller.dart';
import 'package:nihongo_listening/features/practice/data/asset_practice_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/presentation/practice_detail_page.dart';
import 'package:nihongo_listening/features/practice/presentation/practice_list_page.dart';
import 'package:nihongo_listening/features/test/presentation/test_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/practice_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('N2練習教材を開き、順次再生と全問題ループで本文と音声を切り替える', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final exam = await AssetPracticeRepository().getExam(
      'n2_listening_problem1',
    );
    final audio = FakeAudioPlaybackService();
    final learning = FakeLearningRepository();
    final router = GoRouter(
      initialLocation: '/practice',
      routes: [
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeListPage(),
        ),
        GoRoute(
          path: '/practice/:examId/question/:questionId',
          pageBuilder: (context, state) {
            final questionId = state.pathParameters['questionId']!;
            final examId = state.pathParameters['examId']!;
            final change = state.extra is PracticeQuestionChange
                ? state.extra! as PracticeQuestionChange
                : null;
            final page = PracticeDetailPage(
              key: ValueKey('practice-detail-$examId'),
              examId: examId,
              questionId: questionId,
              questionChange: change,
            );
            return MaterialPage<void>(
              key: ValueKey('practice-detail-$examId'),
              child: page,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(exam, supportsTest: false),
          ),
          learningRepositoryProvider.overrideWithValue(learning),
          audioPlaybackServiceProvider.overrideWithValue(audio),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Given: catalogから練習専用の3問教材を一覧表示します。
    expect(find.text('N2聴解・問題1（3問）'), findsOneWidget);

    // When: 教材を開き、問題モードへ切り替えます。
    await tester.tap(find.text('N2聴解・問題1（3問）'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('前の問題'), findsNothing);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第01問.mp3');
    await tester.tap(find.text('問題'));
    await tester.pumpAndSettle();

    // Then: q01の問題文と未収録案内を表示します。
    expect(find.text('男の学生は、この後まず何をしますか'), findsOneWidget);
    expect(find.text('選択肢・正解は未収録です'), findsOneWidget);

    // When / Then: q01の完了時にq02へ進み、同じQuestionの本文と音声pathを表示します。
    await tester.tap(find.byTooltip('再生'));
    await tester.pump();
    final playCountBeforeChange = audio.playCount;
    final pendingQ02 = Completer<Duration>();
    audio.pendingLoads['assets/audio/問題1_第02問.mp3'] = pendingQ02;
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 音源loadが未完了でも目標本文を即時表示し、画面とPlayerにSpinnerを出しません。
    expect(find.text('女の店員はこの後まず、何をしますか。'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(audio.playCount, playCountBeforeChange);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第02問.mp3');

    pendingQ02.complete(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.text('女の店員はこの後まず、何をしますか。'), findsOneWidget);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第02問.mp3');
    expect(audio.playCount, greaterThan(playCountBeforeChange));

    // q02の完了時も順次再生し、q03では末尾境界の右ボタンを生成しません。
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('男の人は何の写真を撮らなければなりませんか。'), findsOneWidget);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第03問.mp3');
    expect(find.byTooltip('次の問題'), findsNothing);

    // 順次再生は末尾で停止し、全問題ループへ変更した場合だけq01へ戻ります。
    final loadCountAtLastQuestion = audio.loadedAssets.length;
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pumpAndSettle();
    expect(audio.loadedAssets.length, loadCountAtLastQuestion);
    expect(find.text('男の人は何の写真を撮らなければなりませんか。'), findsOneWidget);

    await tester.tap(find.byTooltip('問題を順番に再生'));
    await tester.pump();
    await tester.tap(find.byTooltip('再生'));
    await tester.pump();
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('男の学生は、この後まず何をしますか'), findsOneWidget);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第01問.mp3');

    // 単一問題ループではRouteを置換せず、現在音源を先頭から再生します。
    final loadCountBeforeSingleRepeat = audio.loadedAssets.length;
    final playCountBeforeSingleRepeat = audio.playCount;
    await tester.tap(find.byTooltip('すべての問題を繰り返す'));
    await tester.pump();
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pumpAndSettle();
    expect(audio.loadedAssets.length, loadCountBeforeSingleRepeat);
    expect(audio.lastSeekPosition, Duration.zero);
    expect(audio.playCount, greaterThan(playCountBeforeSingleRepeat));
    expect(find.text('男の学生は、この後まず何をしますか'), findsOneWidget);

    // 解説がない教材は空欄や例外ではなく、明示的な案内を表示します。
    await tester.tap(find.text('説明文'));
    await tester.pumpAndSettle();
    expect(find.text('解説は未収録です'), findsOneWidget);

    // 音源load失敗後も目標問題に留まり、SnackBar表示後は戻る操作を行えます。
    await tester.tap(find.text('問題'));
    await tester.pumpAndSettle();
    audio.loadErrors['assets/audio/問題1_第02問.mp3'] = StateError('broken audio');
    await tester.tap(find.byTooltip('次の問題'));
    await tester.pumpAndSettle();
    expect(find.text('女の店員はこの後まず、何をしますか。'), findsOneWidget);
    expect(find.textContaining('音声を読み込めませんでした'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('N2聴解・問題1（3問）'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    await audio.dispose();
  });

  testWidgets('練習専用教材はTest一覧から開始できない', (tester) async {
    const exams = [
      ExamSummary(
        id: 'demo',
        year: 2026,
        month: 7,
        titleJa: '採点可能教材',
        audioQuality: '良い',
        questionCount: 3,
        resourcePath: 'demo.json',
        supportsTest: true,
      ),
      ExamSummary(
        id: 'n2_listening_problem1',
        titleJa: 'N2聴解・問題1（3問）',
        audioQuality: '不明',
        questionCount: 3,
        resourcePath: 'n2.json',
        supportsTest: false,
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examCatalogProvider.overrideWithValue(const AsyncData(exams)),
          testResultsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: MaterialApp(theme: buildDarkTheme(), home: const TestHomePage()),
      ),
    );
    await tester.pump();

    final practiceOnlyTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'N2聴解・問題1（3問）'),
    );
    final gradableTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, '採点可能教材'),
    );
    expect(practiceOnlyTile.onTap, isNull);
    expect(gradableTile.onTap, isNotNull);
    expect(find.text('3問 ・ 練習専用・採点データ未収録'), findsOneWidget);
  });
}
