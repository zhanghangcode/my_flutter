import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';

/// sessionIdごとの提出結果を取得する画面ローカルなfamily Provider。
///
/// family引数の[sessionId]をDrift検索キーとして使用し、結果がない場合は`null`を返します。
final _testResultProvider = FutureProvider.family((ref, int sessionId) {
  return ref.watch(testRepositoryProvider).getResult(sessionId);
});

/// 正答率、集計値、復習対象を表示するテスト結果画面。
///
/// Drift の結果と静的教材を ID で関連付け、誤答問題から練習詳細へ遷移できます。
class TestResultPage extends ConsumerWidget {
  /// 提出済みテストの結果画面を生成します。
  ///
  /// [sessionId]はDriftから復元する提出済みセッションIDです。[key]は任意で、生成時に
  /// テスト結果を変更しません。
  const TestResultPage({super.key, required this.sessionId});

  /// 表示する提出済みテストセッションのIDです。
  final int sessionId;

  @override
  /// 集計、誤答復習、お気に入り操作を含む結果UIを構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    // Route から受け取った sessionId を family Provider のキーとして使用します。
    final result = ref.watch(_testResultProvider(sessionId));
    return Scaffold(
      appBar: AppBar(title: const Text('テスト結果')),
      body: result.when(
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(message: error.toString()),
        data: (item) {
          if (item == null) {
            return const AppEmptyView(
              icon: Icons.search_off,
              message: '結果が見つかりません。',
            );
          }
          final minutes = Duration(milliseconds: item.durationMs).inMinutes;
          final seconds = Duration(
            milliseconds: item.durationMs,
          ).inSeconds.remainder(60);
          final exam = ref.watch(examResourceProvider(item.examId)).value;
          // 未回答を含め、正解 ID と一致しない問題を復習対象として抽出します。
          final wrongQuestions =
              exam?.questions
                  .where(
                    (question) =>
                        item.answers[question.id] != question.correctOptionId,
                  )
                  .toList() ??
              [];
          final favoriteIds =
              ref.watch(favoriteQuestionIdsProvider).value ?? <String>{};
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: SizedBox(
                  width: 190,
                  height: 190,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: item.accuracy,
                        strokeWidth: 14,
                        backgroundColor: AppColors.divider,
                        color: item.accuracy >= 0.7
                            ? AppColors.jade
                            : AppColors.vermillion,
                      ),
                      Center(
                        child: Text(
                          '${(item.accuracy * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ResultRow(label: '問題数', value: '${item.totalCount}'),
                      _ResultRow(label: '正解', value: '${item.correctCount}'),
                      _ResultRow(
                        label: '不正解',
                        value: '${item.totalCount - item.correctCount}',
                      ),
                      _ResultRow(
                        label: '時間',
                        value: '$minutes:${seconds.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
              ),
              if (wrongQuestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  '復習が必要な問題',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                for (final question in wrongQuestions)
                  Card(
                    child: ListTile(
                      title: Text('問題${question.section}-${question.number}番'),
                      subtitle: Text(question.promptJa),
                      onTap: () => context.push(
                        '/practice/${question.examId}/question/${question.id}',
                      ),
                      trailing: IconButton(
                        tooltip: '復習問題をお気に入りに追加',
                        onPressed: () => ref
                            .read(learningRepositoryProvider)
                            .toggleQuestionFavorite(question.id),
                        icon: Icon(
                          favoriteIds.contains(question.id)
                              ? Icons.star
                              : Icons.star_outline,
                          color: favoriteIds.contains(question.id)
                              ? AppColors.gold
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/test'),
                child: const Text('テスト一覧へ'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.go('/favorites'),
                child: const Text('復習リストを見る'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  /// 結果カード内のラベルと値の1行を生成します。
  ///
  /// [label]は項目名、[value]は表示済みの集計値です。
  const _ResultRow({required this.label, required this.value});

  /// 表示する集計項目名です。
  final String label;

  /// 表示する集計値です。
  final String value;

  @override
  /// 左右にラベルと値を配置した結果行を構築します。
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
