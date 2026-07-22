import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/test/presentation/test_home_page.dart';
import 'package:nihongo_listening/features/test/presentation/test_session_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/practice_test_fakes.dart';

/// テストRouteを離れた際に音声再生が確実に止まることを検証します。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('閉じるボタンでテスト一覧へ戻ると再生中の音声を停止する', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final audio = FakeAudioPlaybackService();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(
          path: '/test',
          builder: (context, state) => const TestHomePage(),
        ),
        GoRoute(
          path: '/test/:examId/session',
          builder: (context, state) =>
              TestSessionPage(examId: state.pathParameters['examId']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(_exam),
          ),
          databaseProvider.overrideWithValue(database),
          audioPlaybackServiceProvider.overrideWithValue(audio),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Given: テストを開始すると1問目の音声を自動再生します。
    await tester.tap(find.text('採点可能教材'));
    await tester.pumpAndSettle();
    expect(find.text('問題 1 / 2'), findsOneWidget);
    expect(audio.playCount, greaterThan(0));
    expect(audio.stopCount, 0);

    // When: 閉じるボタンをタップして確認Dialogで終了を選びます。
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('終了'));
    await tester.pumpAndSettle();

    // Then: テスト一覧へ戻り、再生中だった音声が停止されます。
    expect(find.text('採点可能教材'), findsOneWidget);
    expect(audio.stopCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    // Driftのwatch queryはcontainer disposeで0-durationのTimerを予約します。引数なしの
    // pump()はfake_asyncの時計を進めないため、Duration.zeroを渡してtimerを消化します。
    await tester.pump(Duration.zero);
    router.dispose();
    await database.close();
  });
}

const _exam = ExamResource(
  schemaVersion: 2,
  id: 'exam',
  titleJa: '採点可能教材',
  questions: [
    Question(
      id: 'q1',
      examId: 'exam',
      section: 1,
      number: 1,
      type: '課題理解',
      promptJa: '質問1',
      options: [
        AnswerOption(id: 'a', label: 1, textJa: '選択肢A'),
        AnswerOption(id: 'b', label: 2, textJa: '選択肢B'),
      ],
      correctOptionId: 'a',
      audioAssetPath: 'assets/audio/q1.mp3',
      sentences: [],
    ),
    Question(
      id: 'q2',
      examId: 'exam',
      section: 1,
      number: 2,
      type: '課題理解',
      promptJa: '質問2',
      options: [
        AnswerOption(id: 'a', label: 1, textJa: '選択肢A'),
        AnswerOption(id: 'b', label: 2, textJa: '選択肢B'),
      ],
      correctOptionId: 'b',
      audioAssetPath: 'assets/audio/q2.mp3',
      sentences: [],
    ),
  ],
);
