import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/async_states.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/domain/download_state.dart';
import '../../downloads/presentation/download_confirmation_dialog.dart';
import '../../practice/domain/practice_models.dart';

/// 模擬テストの教材一覧と最近の提出結果を表示する入口画面。
class TestHomePage extends ConsumerWidget {
  /// 模擬テスト教材と最近の結果を表示する画面を生成します。
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              _TestExamCard(exam: exam),
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

/// Test開始前のDownload確認と重複Route遷移を管理する試験カード。
class _TestExamCard extends ConsumerStatefulWidget {
  /// [exam]に対応するTestカードを生成します。
  const _TestExamCard({required this.exam});

  /// 表示・開始対象となる試験metadataです。
  final ExamSummary exam;

  @override
  ConsumerState<_TestExamCard> createState() => _TestExamCardState();
}

/// Test入口のDialog・Download・Route遷移を直列化するState。
class _TestExamCardState extends ConsumerState<_TestExamCard> {
  /// Test開始処理の多重実行を防ぐフラグです。
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    final requiresDownload =
        exam.audioDeliveryMode == AudioDeliveryMode.downloadRequired;
    if (exam.supportsTest && requiresDownload) {
      ref.watch(examDownloadCheckProvider(exam.id));
    }
    final downloadState = requiresDownload
        ? ref.watch(downloadControllerProvider)[exam.id] ??
              const ExamDownloadState.notDownloaded()
        : const ExamDownloadState.notDownloaded();
    final subtitle = !exam.supportsTest
        ? '${exam.questionCount}問 ・ 練習専用・採点データ未収録'
        : requiresDownload
        ? downloadState.isDownloading
              ? '${exam.questionCount}問 ・ ダウンロード中 '
                    '${(downloadState.progress * 100).round()}%'
              : downloadState.isDownloaded
              ? '${exam.questionCount}問 ・ ダウンロード済み'
              : downloadState.isFailed
              ? '${exam.questionCount}問 ・ ダウンロード失敗・再試行できます'
              : '${exam.questionCount}問 ・ 音声ダウンロードが必要です'
        : '${exam.questionCount}問 ・ ローカル教材';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: const CircleAvatar(child: Icon(Icons.timer_outlined)),
        title: Text(exam.titleJa),
        subtitle: Text(subtitle),
        trailing: exam.supportsTest
            ? downloadState.isDownloading
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        value: downloadState.progress,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.chevron_right)
            : const Icon(Icons.lock_outline),
        onTap: !exam.supportsTest || _isOpening || downloadState.isDownloading
            ? null
            : _open,
      ),
    );
  }

  /// 必要な音声を確認・保存・再検証してからTest Sessionへ遷移します。
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
      if (mounted) context.push('/test/${widget.exam.id}/session');
    } catch (_) {
      if (mounted) showExamDownloadError(context);
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }
}
