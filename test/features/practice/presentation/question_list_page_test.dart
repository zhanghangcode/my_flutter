import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/presentation/question_list_page.dart';

/// QuestionListPage のsection表示と問題行タップを検証するWidgetテスト群です。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sectionごとに種別と第N問を表示し、行タップで対応する問題detailへ遷移する', (tester) async {
    final exam = _buildExam();
    final router = GoRouter(
      initialLocation: '/practice/exam-1',
      routes: [
        GoRoute(
          path: '/practice/:examId',
          builder: (context, state) =>
              QuestionListPage(examId: state.pathParameters['examId']!),
        ),
        GoRoute(
          path: '/practice/:examId/question/:questionId',
          builder: (context, state) => Scaffold(
            body: Text(
              'detail:${state.pathParameters['examId']}/${state.pathParameters['questionId']}',
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examResourceProvider('exam-1').overrideWith((ref) async => exam),
        ],
        child: MaterialApp.router(
          theme: buildDarkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then: 試験タイトルと、sectionごとの見出しを表示します。既定では折りたたまれており、
    // 問題行はまだ表示しません。
    expect(find.text('2026年7月'), findsOneWidget);
    expect(find.text('問題1 課題理解'), findsOneWidget);
    expect(find.text('問題2 ポイント理解'), findsOneWidget);
    expect(find.text('第1問'), findsNothing);

    // When: 両方のsection見出しをタップして展開します。
    await tester.tap(find.text('問題1 課題理解'));
    await tester.tap(find.text('問題2 ポイント理解'));
    await tester.pumpAndSettle();

    // Then: 展開後は各sectionの問題行を表示します。
    expect(find.text('第1問'), findsNWidgets(2));
    expect(find.text('第2問'), findsOneWidget);

    // When: section2の「第1問」をタップします。
    await tester.tap(find.text('第1問').last);
    await tester.pumpAndSettle();

    // Then: 対応する問題detailへ遷移します。
    expect(find.text('detail:exam-1/q3'), findsOneWidget);
  });

  testWidgets('問題が空の試験ではEmpty表示を出す', (tester) async {
    const exam = ExamResource(
      schemaVersion: 2,
      id: 'exam-empty',
      titleJa: '空の試験',
      questions: [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examResourceProvider('exam-empty').overrideWith((ref) async => exam),
        ],
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const QuestionListPage(examId: 'exam-empty'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('この試験には問題がありません。'), findsOneWidget);
  });
}

/// 2つのsectionにまたがる最小の試験データを生成します。
ExamResource _buildExam() => const ExamResource(
  schemaVersion: 2,
  id: 'exam-1',
  titleJa: '2026年7月',
  questions: [
    Question(
      id: 'q1',
      examId: 'exam-1',
      section: 1,
      number: 1,
      type: '課題理解',
      promptJa: '問題文1',
      options: [],
      audioAssetPath: 'audio/q1.mp3',
      sentences: [],
    ),
    Question(
      id: 'q2',
      examId: 'exam-1',
      section: 1,
      number: 2,
      type: '課題理解',
      promptJa: '問題文2',
      options: [],
      audioAssetPath: 'audio/q2.mp3',
      sentences: [],
    ),
    Question(
      id: 'q3',
      examId: 'exam-1',
      section: 2,
      number: 1,
      type: 'ポイント理解',
      promptJa: '問題文3',
      options: [],
      audioAssetPath: 'audio/q3.mp3',
      sentences: [],
    ),
  ],
);
