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
import '../domain/learning_repository.dart';
import '../domain/practice_models.dart';
import 'widgets/answer_options.dart';
import 'widgets/transcript_list.dart';

/// 本文、問題、組み合わせ、解説を切り替えて学習する練習詳細画面。
///
/// 画面下部の AudioPlayerBar はモード切り替えの外側に置くため、内容を切り替えても
/// 再生状態を維持します。Route の ID を使って教材と保存済み学習状態を復元します。
class PracticeDetailPage extends ConsumerStatefulWidget {
  const PracticeDetailPage({
    super.key,
    required this.examId,
    required this.questionId,
    this.sentenceId,
    this.questionChange,
  });

  final String examId;
  final String questionId;
  final String? sentenceId;
  final PracticeQuestionChange? questionChange;

  @override
  ConsumerState<PracticeDetailPage> createState() => _PracticeDetailPageState();
}

class _PracticeDetailPageState extends ConsumerState<PracticeDetailPage> {
  bool _initializing = false;
  String? _initializedQuestionId;
  LearningRepository? _learningRepository;
  AudioPlayerController? _audioPlayerController;
  AudioPlayerState _latestPlayerState = const AudioPlayerState();
  ContentMode _latestContentMode = ContentMode.transcript;

  @override
  void dispose() {
    // 詳細画面を離れる時点の位置と表示モードを保存し、次回の復元に使用します。
    // dispose では ref を参照できないため、描画中に保持した依存と最新 State を使用します。
    final player = _latestPlayerState;
    if (player.questionId == widget.questionId) {
      final repository = _learningRepository;
      if (repository != null) {
        unawaited(
          repository.saveProgress(
            widget.questionId,
            positionMs: player.position.inMilliseconds,
            contentMode: _latestContentMode,
          ),
        );
      }
      final controller = _audioPlayerController;
      if (controller != null) unawaited(controller.stop());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 教材・お気に入り・演習状態を watch し、各 State の変更を画面へ反映します。
    final question = ref.watch(questionProvider(widget.questionId));
    final favoriteIds = ref.watch(favoriteQuestionIdsProvider).value ?? {};
    final detail = ref.watch(practiceDetailControllerProvider);
    final player = ref.watch(audioPlayerControllerProvider);
    // Route の破棄時は ref.read を使えないため、必要な依存と State を事前に保持します。
    _learningRepository = ref.read(learningRepositoryProvider);
    _audioPlayerController = ref.read(audioPlayerControllerProvider.notifier);
    _latestPlayerState = player;
    _latestContentMode = detail.mode;
    return PopScope(
      canPop: !detail.isChangingQuestion,
      child: Scaffold(
        appBar: AppBar(
          title: question.maybeWhen(
            data: (item) => GestureDetector(
              onTap: detail.isChangingQuestion
                  ? null
                  : () => _showQuestionPicker(context),
              child: Text('問題${item.section}-${item.number}番'),
            ),
            orElse: () => const Text('練習'),
          ),
          actions: [
            IconButton(
              tooltip: '問題をお気に入りに追加',
              onPressed: question.hasValue && !detail.isChangingQuestion
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
            // build 中に Provider の State を変更しないよう、初期化は描画後へ予約します。
            _scheduleInitialization(item);
            final canNavigateQuestions =
                !detail.isChangingQuestion &&
                !detail.loading &&
                player.status != AudioPlayerStatus.loading;
            return Stack(
              children: [
                Column(
                  children: [
                    // Expanded がスクロール可能な内容領域を確保し、操作部の重なりを防ぎます。
                    Expanded(
                      child: KeyedSubtree(
                        key: ValueKey('${item.id}-${detail.mode.name}'),
                        child: _buildContent(item, detail.mode),
                      ),
                    ),
                    _ModeSelector(
                      selected: detail.mode,
                      onSelected: detail.isChangingQuestion
                          ? (_) {}
                          : (mode) {
                              ref
                                  .read(
                                    practiceDetailControllerProvider.notifier,
                                  )
                                  .setMode(mode);
                            },
                    ),
                    AudioPlayerBar(
                      showPreviousQuestion: detail.hasPreviousQuestion,
                      showNextQuestion: detail.hasNextQuestion,
                      questionNavigationEnabled: canNavigateQuestions,
                      onPreviousQuestion: () => _changeQuestion(-1),
                      onNextQuestion: () => _changeQuestion(1),
                    ),
                  ],
                ),
                if (detail.isChangingQuestion)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x99070707),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
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
    // 非同期初期化の多重実行を防ぎ、同じ問題の音声を再読み込みしません。
    if (_initializing || _initializedQuestionId == question.id) return;
    _initializing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final change = widget.questionChange?.questionId == question.id
          ? widget.questionChange
          : null;
      try {
        // 学習状態、設定、再生位置の順で復元してから音声を準備します。
        await ref
            .read(practiceDetailControllerProvider.notifier)
            .open(question.id, preferredMode: change?.mode);
        if (!mounted) return;
        final settings =
            ref.read(settingsControllerProvider).value ?? const AppSettings();
        final progress = change == null
            ? await ref
                  .read(learningRepositoryProvider)
                  .getProgress(question.id)
            : null;
        if (!mounted) return;
        await ref
            .read(audioPlayerControllerProvider.notifier)
            .loadQuestion(
              question,
              speed: settings.defaultSpeed,
              restorePosition: change == null && settings.rememberPosition
                  ? Duration(milliseconds: progress?.lastPositionMs ?? 0)
                  : Duration.zero,
            );
        if (!mounted) return;
        final targetSentence = question.sentences
            .where((sentence) => sentence.id == widget.sentenceId)
            .firstOrNull;
        if (targetSentence != null) {
          // お気に入りの文から開いた場合は、指定文の開始位置へ移動します。
          await ref
              .read(audioPlayerControllerProvider.notifier)
              .seekToSentence(targetSentence);
        }
        if (change?.resumePlayback ?? false) {
          final player = ref.read(audioPlayerControllerProvider);
          if (player.questionId == question.id &&
              player.status != AudioPlayerStatus.loading &&
              player.status != AudioPlayerStatus.error &&
              !player.isPlaying) {
            await ref
                .read(audioPlayerControllerProvider.notifier)
                .togglePlayPause();
          }
        }
        _initializedQuestionId = question.id;
      } finally {
        if (mounted) {
          ref
              .read(practiceDetailControllerProvider.notifier)
              .completeQuestionChange(question.id);
        }
        _initializing = false;
      }
    });
  }

  Future<void> _changeQuestion(int offset) async {
    final player = ref.read(audioPlayerControllerProvider);
    final settings =
        ref.read(settingsControllerProvider).value ?? const AppSettings();
    final change = await ref
        .read(practiceDetailControllerProvider.notifier)
        .changeQuestion(
          offset,
          speed: player.hasSource ? player.speed : settings.defaultSpeed,
        );
    await _replaceWithQuestion(change);
  }

  Future<void> _changeToQuestion(String questionId) async {
    final player = ref.read(audioPlayerControllerProvider);
    final settings =
        ref.read(settingsControllerProvider).value ?? const AppSettings();
    final change = await ref
        .read(practiceDetailControllerProvider.notifier)
        .changeToQuestion(
          questionId,
          speed: player.hasSource ? player.speed : settings.defaultSpeed,
        );
    await _replaceWithQuestion(change);
  }

  Future<void> _replaceWithQuestion(PracticeQuestionChange? change) async {
    if (!mounted) return;
    if (change == null) {
      final error = ref.read(practiceDetailControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    context.pushReplacement(
      '/practice/${change.examId}/question/${change.questionId}',
      extra: change,
    );
  }

  Future<void> _showQuestionPicker(BuildContext context) async {
    // BottomSheet は同じ試験内の問題だけを表示し、選択時に現在 Route を置換します。
    final exam = await ref.read(examResourceProvider(widget.examId).future);
    if (!context.mounted) return;
    final selectedQuestionId = await showModalBottomSheet<String>(
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
                onTap: () => Navigator.of(sheetContext).pop(question.id),
              ),
          ],
        ),
      ),
    );
    if (selectedQuestionId != null &&
        selectedQuestionId != widget.questionId &&
        mounted) {
      await _changeToQuestion(selectedQuestionId);
    }
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

/// 問題文と回答選択肢を、単独表示と組み合わせ表示で共有するセクション。
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

/// 設定に応じて日本語解説と中国語訳を表示する内容 Widget。
class _ExplanationContent extends ConsumerWidget {
  const _ExplanationContent({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explanation = question.explanation;
    if (explanation == null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            '解説',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                '解説は未収録です',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ),
        ],
      );
    }
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
        Text(explanation.ja, style: const TextStyle(fontSize: 17, height: 1.6)),
        if (showChinese) ...[
          const SizedBox(height: 20),
          const Text('中国語翻訳', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Text(
            explanation.zh,
            style: const TextStyle(fontSize: 17, height: 1.6),
          ),
          if (explanation.optionReasonsZh.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '選択肢のポイント',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final entry in explanation.optionReasonsZh.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${entry.key.toUpperCase()}: ${entry.value}'),
              ),
          ],
        ],
        const SizedBox(height: 24),
        if (question.isGradable)
          Text(
            '正解: ${question.options.firstWhere((option) => option.id == question.correctOptionId).label}',
          ),
      ],
    );
  }
}

/// 4 つの内容モードを切り替える詳細画面専用のセレクター。
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
