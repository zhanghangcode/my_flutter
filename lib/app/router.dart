import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/favorites/presentation/favorites_page.dart';
import '../features/practice/presentation/practice_detail_page.dart';
import '../features/practice/presentation/practice_list_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/test/presentation/test_home_page.dart';
import '../features/test/presentation/test_result_page.dart';
import '../features/test/presentation/test_session_page.dart';
import 'shell_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/practice',
  routes: [
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
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/practice/:examId/question/:questionId',
      builder: (context, state) => PracticeDetailPage(
        key: ValueKey(state.pathParameters['questionId']),
        examId: state.pathParameters['examId']!,
        questionId: state.pathParameters['questionId']!,
        sentenceId: state.uri.queryParameters['sentenceId'],
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/test/:examId/session',
      builder: (context, state) => TestSessionPage(
        key: ValueKey(state.pathParameters['examId']),
        examId: state.pathParameters['examId']!,
      ),
    ),
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
