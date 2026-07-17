import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../domain/practice_models.dart';

class PracticeListPage extends ConsumerWidget {
  const PracticeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _ExamCard extends ConsumerWidget {
  const _ExamCard({required this.exam});

  final ExamSummary exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context, ref),
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

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    try {
      final resource = await ref.read(examResourceProvider(exam.id).future);
      if (!context.mounted) return;
      if (resource.questions.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('この教材には問題がありません。')));
        return;
      }
      final first = resource.questions.first;
      await context.push('/practice/${exam.id}/question/${first.id}');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
