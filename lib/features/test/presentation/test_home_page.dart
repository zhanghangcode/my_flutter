import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/async_states.dart';

/// 模擬テストの教材一覧と最近の提出結果を表示する入口画面。
///
/// Scaffold と AppBar の下に試験カードと履歴を並べ、選択した試験は
/// GoRouter を通して全画面のテストセッションへ遷移します。
class TestHomePage extends ConsumerWidget {
  /// 模擬テスト教材と最近の結果を表示する画面を生成します。
  ///
  /// [key]は任意のWidget識別子です。テストセッションはカードのタップ時だけ開始します。
  const TestHomePage({super.key});

  @override
  /// 教材一覧とテスト結果Providerを購読した入口画面を構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    // 教材と結果の Provider を watch し、追加・提出された内容を一覧へ反映します。
    final exams = ref.watch(examCatalogProvider);
    final results = ref.watch(testResultsProvider).value ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('テスト')),
      body: exams.when(
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(examCatalogProvider),
        ),
        data: (items) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '模擬テスト',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              '本文と解説を見ずに、音声を一度だけ聞いて回答します。',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            for (final exam in items) ...[
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const CircleAvatar(
                    child: Icon(Icons.timer_outlined),
                  ),
                  title: Text(exam.titleJa),
                  subtitle: Text(
                    exam.supportsTest
                        ? '${exam.questionCount}問 ・ ローカル教材'
                        : '${exam.questionCount}問 ・ 練習専用・採点データ未収録',
                  ),
                  trailing: Icon(
                    exam.supportsTest
                        ? Icons.chevron_right
                        : Icons.lock_outline,
                  ),
                  onTap: exam.supportsTest
                      ? () => context.push('/test/${exam.id}/session')
                      : null,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (results.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                '最近の結果',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (final result in results.take(5))
                ListTile(
                  leading: const Icon(Icons.insights),
                  title: Text(
                    '${result.correctCount} / ${result.totalCount} 正解',
                  ),
                  subtitle: Text('正答率 ${(result.accuracy * 100).round()}%'),
                  onTap: () => context.push('/test/result/${result.sessionId}'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
