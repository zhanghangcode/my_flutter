import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_states.dart';
import '../../player/application/audio_player_controller.dart';
import '../../practice/presentation/widgets/answer_options.dart';
import '../application/test_session_controller.dart';

/// 原文と正解を隠して問題を順番に解くテスト実施画面。
///
/// State の初期化と音声停止を画面ライフサイクルに連動させるため、
/// ConsumerStatefulWidget として実装しています。
class TestSessionPage extends ConsumerStatefulWidget {
  const TestSessionPage({super.key, required this.examId});

  final String examId;

  @override
  ConsumerState<TestSessionPage> createState() => _TestSessionPageState();
}

class _TestSessionPageState extends ConsumerState<TestSessionPage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // initState 中に Provider を更新せず、現在の同期処理が終わった後に開始します。
    Future.microtask(() async {
      if (!_started) {
        _started = true;
        await ref
            .read(testSessionControllerProvider.notifier)
            .start(widget.examId);
      }
    });
  }

  @override
  void dispose() {
    // Route を離れた後もテスト音声が再生され続けないよう停止します。
    unawaited(ref.read(audioPlayerControllerProvider.notifier).stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AsyncValue を watch し、開始処理の loading・error・data を切り替えます。
    final sessionAsync = ref.watch(testSessionControllerProvider);
    return PopScope(
      // システムの戻る操作も確認 Dialog を経由させ、誤終了を防ぎます。
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => _confirmExit(context),
            icon: const Icon(Icons.close),
          ),
          title: const Text('テスト中'),
        ),
        body: sessionAsync.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref
                .read(testSessionControllerProvider.notifier)
                .start(widget.examId),
          ),
          data: (session) {
            if (session == null) return const AppLoadingView();
            final question = session.currentQuestion;
            final player = ref.watch(audioPlayerControllerProvider);
            return Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (session.currentIndex + 1) /
                      session.exam.questions.length,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Row(
                        children: [
                          Text(
                            '問題 ${session.currentIndex + 1} / ${session.exam.questions.length}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const Spacer(),
                          Icon(
                            player.isPlaying
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: player.isPlaying
                                ? Colors.white
                                : Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            player.isPlaying ? '再生中' : '再生終了',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Chip(label: Text(question.type)),
                      const SizedBox(height: 12),
                      Text(
                        question.promptJa,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      AnswerOptions(
                        question: question,
                        showPracticeActions: false,
                        testSelection: session.answers[question.id],
                        onTestSelect: ref
                            .read(testSessionControllerProvider.notifier)
                            .select,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  // 回答操作を Home Indicator やシステムナビゲーションから離します。
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: session.currentIndex > 0
                              ? () => ref
                                    .read(
                                      testSessionControllerProvider.notifier,
                                    )
                                    .goTo(session.currentIndex - 1)
                              : null,
                          child: const Text('戻る'),
                        ),
                        const Spacer(),
                        if (session.currentIndex <
                            session.exam.questions.length - 1)
                          FilledButton(
                            onPressed: () => ref
                                .read(testSessionControllerProvider.notifier)
                                .goTo(session.currentIndex + 1),
                            child: const Text('次へ'),
                          )
                        else
                          FilledButton(
                            onPressed: () => _submit(context),
                            child: const Text('提出する'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final result = await ref
        .read(testSessionControllerProvider.notifier)
        .submit();
    if (result != null && context.mounted) {
      // 提出完了後は sessionId を Route に渡し、保存済み結果を表示します。
      context.go('/test/result/${result.sessionId}');
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    // 未提出回答が保存されないことを明示し、ユーザーの確認を得ます。
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('テストを終了しますか？'),
        content: const Text('未提出の回答は結果に保存されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('続ける'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('終了'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) context.go('/test');
  }
}
