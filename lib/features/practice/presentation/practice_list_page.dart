import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/domain/download_state.dart';
import '../../downloads/presentation/download_confirmation_dialog.dart';
import '../domain/practice_models.dart';

/// 利用可能な試験をカードで表示する練習の入口画面。
class PracticeListPage extends ConsumerWidget {
  /// 練習教材一覧を表示する画面を生成します。
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

/// 1試験分のLocal利用状態と、重複操作を防ぐ開く処理を管理するカード。
class _ExamCard extends ConsumerStatefulWidget {
  /// [exam]に対応する教材カードを生成します。
  const _ExamCard({required this.exam});

  /// 表示・遷移対象となる試験metadataです。
  final ExamSummary exam;

  @override
  ConsumerState<_ExamCard> createState() => _ExamCardState();
}

/// Dialog・Download・Route遷移を1回に直列化するカードState。
class _ExamCardState extends ConsumerState<_ExamCard> {
  /// Dialog表示からRoute遷移までの多重実行を防ぐフラグです。
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final requiresDownload =
        exam.audioDeliveryMode == AudioDeliveryMode.downloadRequired;
    if (requiresDownload) {
      ref.watch(examDownloadCheckProvider(exam.id));
    }
    final downloadState = requiresDownload
        ? ref.watch(downloadControllerProvider)[exam.id] ??
              const ExamDownloadState.notDownloaded()
        : ExamDownloadState.downloaded(
            localAudioPaths: const {},
            resourceVersion: exam.audioResourceVersion,
          );
    final isLocked = _isOpening || downloadState.isDownloading;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLocked ? null : _open,
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
                    const SizedBox(height: 5),
                    _DownloadStatusLine(
                      bundled: !requiresDownload,
                      state: downloadState,
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

  /// 必要な場合だけ確認・保存・再検証を行い、問題一覧へ1回だけ遷移します。
  Future<void> _open() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    try {
      final exam = widget.exam;
      if (exam.audioDeliveryMode == AudioDeliveryMode.downloadRequired) {
        final resource = await ref.read(examResourceProvider(exam.id).future);
        final controller = ref.read(downloadControllerProvider.notifier);
        final alreadyDownloaded = await controller.ensureStatusChecked(
          exam,
          resource,
        );
        if (!mounted) return;
        if (!alreadyDownloaded) {
          final confirmed = await showExamDownloadConfirmation(context, exam);
          if (!mounted || !confirmed) return;
          try {
            final completed = await controller.download(exam, resource);
            if (!completed ||
                !await controller.ensureStatusChecked(exam, resource)) {
              throw StateError('download verification failed');
            }
          } catch (_) {
            if (mounted) showExamDownloadError(context);
            return;
          }
        }
      }
      if (!mounted) return;
      context.push('/practice/${widget.exam.id}');
    } catch (_) {
      if (mounted) showExamDownloadError(context);
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }
}

/// 配送方式と現在Stateに応じて、カード内の利用状態・進捗を表示します。
class _DownloadStatusLine extends StatelessWidget {
  /// bundledまたはDownload Stateを表示するWidgetを生成します。
  const _DownloadStatusLine({required this.bundled, required this.state});

  /// Bundle Assetを直接利用できる教材かを示します。
  final bool bundled;

  /// Download必須教材の現在Stateです。
  final ExamDownloadState state;

  @override
  Widget build(BuildContext context) {
    if (state.isDownloading) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceHigh,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(state.progress * 100).round()}%',
            style: const TextStyle(color: AppColors.accent, fontSize: 12),
          ),
        ],
      );
    }
    final (icon, text, color) = bundled
        ? (Icons.offline_pin, 'ローカルで利用可能', AppColors.success)
        : state.isDownloaded
        ? (Icons.offline_pin, 'ダウンロード済み', AppColors.success)
        : state.isFailed
        ? (Icons.error_outline, 'ダウンロード失敗・タップして再試行', AppColors.accent)
        : (Icons.cloud_download_outlined, 'タップしてダウンロード', Colors.white38);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 12)),
        ),
      ],
    );
  }
}
