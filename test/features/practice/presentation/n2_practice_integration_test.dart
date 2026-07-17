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

  testWidgets('N2練習教材を開き、questionIdに対応する本文と音声へ切り替える', (tester) async {
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
          builder: (context, state) {
            final questionId = state.pathParameters['questionId']!;
            final change = state.extra is PracticeQuestionChange
                ? state.extra! as PracticeQuestionChange
                : null;
            return PracticeDetailPage(
              key: ValueKey(questionId),
              examId: state.pathParameters['examId']!,
              questionId: questionId,
              questionChange: change,
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

    // When / Then: q02へ移動すると同じQuestionの本文と音声pathへ切り替わります。
    await tester.tap(find.byTooltip('次の問題'));
    await tester.pumpAndSettle();
    expect(find.text('女の店員はこの後まず、何をしますか。'), findsOneWidget);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第02問.mp3');

    // q03では末尾境界となり、右ボタンを生成しません。
    await tester.tap(find.byTooltip('次の問題'));
    await tester.pumpAndSettle();
    expect(find.text('男の人は何の写真を撮らなければなりませんか。'), findsOneWidget);
    expect(audio.loadedAssets.last, 'assets/audio/問題1_第03問.mp3');
    expect(find.byTooltip('次の問題'), findsNothing);

    // 解説がない教材は空欄や例外ではなく、明示的な案内を表示します。
    await tester.tap(find.text('説明文'));
    await tester.pumpAndSettle();
    expect(find.text('解説は未収録です'), findsOneWidget);

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
