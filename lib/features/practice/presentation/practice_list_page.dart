import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../domain/practice_models.dart';

/// 利用可能な試験を年月単位のカードで表示する練習の入口画面。
///
/// Scaffold と AppBar で主画面の枠を作り、FutureProvider の状態に応じて
/// 読み込み中・エラー・空状態・教材一覧を切り替えます。
class PracticeListPage extends ConsumerWidget {
  /// 利用可能な練習教材を表示する画面を生成します。
  ///
  /// [key]は任意のWidget識別子で、生成時に教材読み込みを直接開始しません。
  const PracticeListPage({super.key});

  @override
  /// 教材一覧Providerの状態に応じた練習一覧UIを構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch により、再試行や更新で catalog が変わると画面も再 build されます。
    final catalog = ref.watch(examCatalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('練習')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(examCatalogProvider),
        child: catalog.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(examCatalogProvider),
          ),
          data: (exams) {
            if (exams.isEmpty) {
              return const AppEmptyView(
                icon: Icons.library_music_outlined,
                message: '利用できる教材がありません。\nassets/data に教材を追加してください。',
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: exams.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ExamCard(exam: exams[index]),
            );
          },
        ),
      ),
    );
  }
}

/// 1 回分の試験情報とローカル利用状態を表示するカード。
class _ExamCard extends StatelessWidget {
  /// 1件の試験教材を開くカードを生成します。
  ///
  /// [exam]は表示する試験メタデータです。カードを生成しただけではRoute遷移は行いません。
  const _ExamCard({required this.exam});

  /// カードへ表示する試験メタデータです。
  final ExamSummary exam;

  @override
  /// 試験情報とタップ可能なカードUIを構築します。
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/practice/${exam.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.graphic_eq, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.titleJa,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '音質: ${exam.audioQuality}  ・  ${exam.questionCount}問',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.offline_pin,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ローカルで利用可能',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
