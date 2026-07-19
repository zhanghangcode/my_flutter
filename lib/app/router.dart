import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/favorites/presentation/favorites_page.dart';
import '../features/practice/application/practice_detail_controller.dart';
import '../features/practice/presentation/practice_detail_page.dart';
import '../features/practice/presentation/practice_list_page.dart';
import '../features/practice/presentation/question_list_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/test/presentation/test_home_page.dart';
import '../features/test/presentation/test_result_page.dart';
import '../features/test/presentation/test_session_page.dart';
import 'shell_page.dart';

/// 詳細画面をBottom Navigationより上に全画面表示するルートNavigatorのKeyです。
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// アプリ全体の画面構成と遷移規則を管理する GoRouter。
///
/// URL 形式の Route を一元管理することで、画面側はパスとパラメータだけを指定して
/// 遷移できます。StatefulShellRoute の各 branch は独立した Navigator を持つため、
/// Bottom Navigation を切り替えても各タブのナビゲーションスタックが保持されます。
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // SplashはShellの外に置き、起動中にBottom Navigationを表示しません。
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        child: const SplashPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    // 4 つの主要画面は indexedStack 上に保持し、非表示タブの State を破棄しません。
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShellPage(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/practice',
              builder: (context, state) => const PracticeListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => const TestHomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    // 問題一覧はsection単位の内訳を表示し、Bottom Navigationを隠して全画面表示します。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/practice/:examId',
      builder: (context, state) =>
          QuestionListPage(examId: state.pathParameters['examId']!),
    ),
    // 練習詳細はルート Navigator へ積み、Bottom Navigation を隠して表示します。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/practice/:examId/question/:questionId',
      // GoRouterState から path/query parameter を取り出し、画面の入力値へ変換します。
      pageBuilder: (context, state) {
        final questionId = state.pathParameters['questionId']!;
        final examId = state.pathParameters['examId']!;
        final questionChange = switch (state.extra) {
          final PracticeQuestionChange value
              when value.questionId == questionId =>
            value,
          _ => null,
        };
        final page = PracticeDetailPage(
          key: ValueKey('practice-detail-$examId'),
          examId: examId,
          questionId: questionId,
          sentenceId: state.uri.queryParameters['sentenceId'],
          questionChange: questionChange,
        );
        // 同一試験の問題は同じPageとして更新し、初回表示だけ標準Route遷移を行います。
        return MaterialPage<void>(
          key: ValueKey('practice-detail-$examId'),
          child: page,
        );
      },
    ),
    // テスト中は主タブから独立した全画面フローとして扱います。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/test/:examId/session',
      builder: (context, state) => TestSessionPage(
        key: ValueKey(state.pathParameters['examId']),
        examId: state.pathParameters['examId']!,
      ),
    ),
    // sessionId を使って Drift に保存された提出結果を再表示します。
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/test/result/:sessionId',
      builder: (context, state) => TestResultPage(
        sessionId: int.tryParse(state.pathParameters['sessionId'] ?? '') ?? 0,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('ページエラー')),
    body: Center(child: Text(state.error.toString())),
  ),
);
