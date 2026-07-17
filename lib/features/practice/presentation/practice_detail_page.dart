import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../player/application/audio_player_controller.dart';
import '../../player/presentation/audio_player_bar.dart';
import '../../settings/domain/app_settings.dart';
import '../application/practice_detail_controller.dart';
import '../domain/practice_models.dart';
import 'widgets/answer_options.dart';
import 'widgets/transcript_list.dart';

class PracticeDetailPage extends ConsumerStatefulWidget {
  const PracticeDetailPage({
    super.key,
    required this.examId,
    required this.questionId,
    this.sentenceId,
  });

  final String examId;
  final String questionId;
  final String? sentenceId;

  @override
  ConsumerState<PracticeDetailPage> createState() => _PracticeDetailPageState();
}

class _PracticeDetailPageState extends ConsumerState<PracticeDetailPage> {
  bool _initializing = false;
  String? _initializedQuestionId;

  @override
  void dispose() {
    final player = ref.read(audioPlayerControllerProvider);
    final detail = ref.read(practiceDetailControllerProvider);
    if (player.questionId == widget.questionId) {
      unawaited(
        ref
            .read(learningRepositoryProvider)
            .saveProgress(
              widget.questionId,
              positionMs: player.position.inMilliseconds,
              contentMode: detail.mode,
            ),
      );
      unawaited(ref.read(audioPlayerControllerProvider.notifier).stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = ref.watch(questionProvider(widget.questionId));
    final favoriteIds = ref.watch(favoriteQuestionIdsProvider).value ?? {};
    final detail = ref.watch(practiceDetailControllerProvider);
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: question.maybeWhen(
            data: (item) => GestureDetector(
              onTap: () => _showQuestionPicker(context),
              child: Text('問題${item.section}-${item.number}番'),
            ),
            orElse: () => const Text('練習'),
          ),
          actions: [
            IconButton(
              tooltip: '問題をお気に入りに追加',
              onPressed: question.hasValue
                  ? () => ref
                        .read(learningRepositoryProvider)
                        .toggleQuestionFavorite(widget.questionId)
                  : null,
              icon: Icon(
                favoriteIds.contains(widget.questionId)
                    ? Icons.star
                    : Icons.star_outline,
                color: favoriteIds.contains(widget.questionId)
                    ? Colors.amber
                    : Colors.white,
              ),
            ),
          ],
        ),
        body: question.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(questionProvider(widget.questionId)),
          ),
          data: (item) {
            _scheduleInitialization(item);
            return Column(
              children: [
                Expanded(child: _buildContent(item, detail.mode)),
                _ModeSelector(
                  selected: detail.mode,
                  onSelected: (mode) {
                    ref
                        .read(practiceDetailControllerProvider.notifier)
                        .setMode(mode);
                  },
                ),
                const AudioPlayerBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(Question question, ContentMode mode) {
    return switch (mode) {
      ContentMode.transcript => TranscriptList(question: question),
      ContentMode.question => _QuestionContent(question: question),
      ContentMode.combined => TranscriptList(
        question: question,
        footer: _QuestionSection(question: question),
      ),
      ContentMode.explanation => _ExplanationContent(question: question),
    };
  }

  void _scheduleInitialization(Question question) {
    if (_initializing || _initializedQuestionId == question.id) return;
    _initializing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref
            .read(practiceDetailControllerProvider.notifier)
            .open(question.id);
        final settings =
            ref.read(settingsControllerProvider).value ?? const AppSettings();
        final progress = await ref
            .read(learningRepositoryProvider)
            .getProgress(question.id);
        await ref
            .read(audioPlayerControllerProvider.notifier)
            .loadQuestion(
              question,
              speed: settings.defaultSpeed,
              restorePosition: settings.rememberPosition
                  ? Duration(milliseconds: progress?.lastPositionMs ?? 0)
                  : Duration.zero,
            );
        final targetSentence = question.sentences
            .where((sentence) => sentence.id == widget.sentenceId)
            .firstOrNull;
        if (targetSentence != null) {
          await ref
              .read(audioPlayerControllerProvider.notifier)
              .seekToSentence(targetSentence);
        }
        _initializedQuestionId = question.id;
      } finally {
        _initializing = false;
      }
    });
  }

  Future<void> _showQuestionPicker(BuildContext context) async {
    final exam = await ref.read(examResourceProvider(widget.examId).future);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const ListTile(
              title: Text('問題を選ぶ'),
              leading: Icon(Icons.format_list_numbered),
            ),
            for (final question in exam.questions)
              ListTile(
                selected: question.id == widget.questionId,
                title: Text('問題${question.section}-${question.number}番'),
                subtitle: Text(question.type),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.pushReplacement(
                    '/practice/${widget.examId}/question/${question.id}',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestionContent extends StatelessWidget {
  const _QuestionContent({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: _QuestionSection(question: question),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  const _QuestionSection({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Chip(label: Text(question.type)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question.promptJa,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        AnswerOptions(question: question),
      ],
    );
  }
}

class _ExplanationContent extends ConsumerWidget {
  const _ExplanationContent({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).value;
    final showChinese = settings?.showChinese ?? true;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '解説',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          question.explanation.ja,
          style: const TextStyle(fontSize: 17, height: 1.6),
        ),
        if (showChinese) ...[
          const SizedBox(height: 20),
          const Text('中国語翻訳', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Text(
            question.explanation.zh,
            style: const TextStyle(fontSize: 17, height: 1.6),
          ),
          if (question.explanation.optionReasonsZh.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '選択肢のポイント',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final entry in question.explanation.optionReasonsZh.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${entry.key.toUpperCase()}: ${entry.value}'),
              ),
          ],
        ],
        const SizedBox(height: 24),
        Text(
          '正解: ${question.options.firstWhere((option) => option.id == question.correctOptionId).label}',
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onSelected});

  final ContentMode selected;
  final ValueChanged<ContentMode> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      ContentMode.transcript: 'テキスト',
      ContentMode.question: '問題',
      ContentMode.combined: 'テキ・問',
      ContentMode.explanation: '説明文',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            for (final mode in ContentMode.values)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(mode),
                  borderRadius: BorderRadius.circular(11),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected == mode
                          ? Colors.white24
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      labels[mode]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: selected == mode
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
