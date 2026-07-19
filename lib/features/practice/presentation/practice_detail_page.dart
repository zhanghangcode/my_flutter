import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../player/application/audio_player_controller.dart';
import '../../player/domain/question_playback_mode.dart';
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
  /// Route から受け取った教材と、任意の問題切り替え情報で詳細画面を構築します。
  ///
  /// [questionChange] がある場合は、前画面で確定した対象問題をすぐに描画しつつ、
  /// 音声と学習状態の初期化を背景で進めます。
  const PracticeDetailPage({
    super.key,
    required this.examId,
    required this.questionId,
    this.sentenceId,
    this.questionChange,
  });

  /// 問題が属する試験を識別し、問題一覧の取得に使用する ID。
  final String examId;

  /// 初回表示する問題を一意に識別する ID。
  final String questionId;

  /// お気に入り画面などから指定された場合に、初期表示時に位置を合わせる文の ID。
  final String? sentenceId;

  /// 同一試験内の問題切り替えで引き継ぐ、表示・再生に必要な一時情報。
  final PracticeQuestionChange? questionChange;

  /// この画面固有の初期化と、画面離脱時の進捗保存を担当する State を生成します。
  @override
  ConsumerState<PracticeDetailPage> createState() => _PracticeDetailPageState();
}

/// PracticeDetailPage の非同期初期化、音声完了時の遷移、進捗保存を管理する State。
///
/// Provider の値は build 中に監視し、dispose 後も保存処理を安全に開始できるよう、
/// 必要な依存と最新の表示状態だけを保持します。
class _PracticeDetailPageState extends ConsumerState<PracticeDetailPage> {
  /// 同じ問題に対する初期化処理を重ねて開始しないためのフラグ。
  bool _initializing = false;

  /// 初期化を完了した問題 ID。再 build 時の音声再読込を防ぎます。
  String? _initializedQuestionId;

  /// dispose 時に最後の進捗を保存するため、build 中に取得して保持する Repository。
  LearningRepository? _learningRepository;

  /// dispose 時に音声を停止するため、build 中に取得して保持する Controller。
  AudioPlayerController? _audioPlayerController;

  /// dispose 時に参照する、最後に描画されたプレイヤー状態。
  AudioPlayerState _latestPlayerState = const AudioPlayerState();

  /// dispose 時に進捗へ保存する、最後に選択されていた表示モード。
  ContentMode _latestContentMode = ContentMode.transcript;

  /// 連続再生による問題自動遷移を重複して開始しないためのフラグ。
  bool _automaticAdvanceInProgress = false;

  /// Route 置換中に dispose が旧問題の音声を停止しないようにするフラグ。
  bool _routeReplacementInProgress = false;

  /// 同じ State に別問題が渡された場合、問題固有の初期化済み情報をリセットします。
  @override
  void didUpdateWidget(covariant PracticeDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId == widget.questionId) return;
    // 同一PageでRoute情報だけを更新し、本文はquestionId付きKeyで先頭から再生成します。
    _initializedQuestionId = null;
    _routeReplacementInProgress = false;
    _automaticAdvanceInProgress = false;
  }

  /// 画面離脱時に進捗を保存し、現在画面が所有する音声だけを停止します。
  @override
  void dispose() {
    // 詳細画面を離れる時点の位置と表示モードを保存し、次回の復元に使用します。
    // dispose では ref を参照できないため、描画中に保持した依存と最新 State を使用します。
    final player = _latestPlayerState;
    if (!_routeReplacementInProgress &&
        player.questionId == widget.questionId) {
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

  /// 問題本文、学習状態、AudioPlayerBar を組み合わせて詳細画面を描画します。
  ///
  /// 同一試験内の切り替えでは [PracticeQuestionChange] の問題を優先することで、
  /// Repository の再取得完了を待たずに次の問題本文を表示します。
  @override
  Widget build(BuildContext context) {
    // 教材・お気に入り・演習状態を watch し、各 State の変更を画面へ反映します。
    final providedQuestion =
        widget.questionChange?.questionId == widget.questionId
        ? widget.questionChange?.question
        : null;
    final providerQuestion = ref.watch(questionProvider(widget.questionId));
    final AsyncValue<Question> question = providedQuestion == null
        ? providerQuestion
        : AsyncData(providedQuestion);
    final favoriteIds = ref.watch(favoriteQuestionIdsProvider).value ?? {};
    final detail = ref.watch(practiceDetailControllerProvider);
    final player = ref.watch(audioPlayerControllerProvider);
    ref.listen<AudioPlayerState>(audioPlayerControllerProvider, (
      previous,
      next,
    ) {
      // completed へ変化した瞬間だけ処理し、同一イベントでの多重遷移を防ぎます。
      if (previous?.status != AudioPlayerStatus.completed &&
          next.status == AudioPlayerStatus.completed &&
          next.questionId == widget.questionId) {
        unawaited(_handlePlaybackCompleted(next));
      }
    });
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
                !detail.isChangingQuestion && !detail.loading;
            return Column(
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
                              .read(practiceDetailControllerProvider.notifier)
                              .setMode(mode);
                        },
                ),
                AudioPlayerBar(
                  showPreviousQuestion: detail.hasPreviousQuestion,
                  showNextQuestion: detail.hasNextQuestion,
                  questionNavigationEnabled: canNavigateQuestions,
                  interactionEnabled:
                      !detail.isChangingQuestion && !detail.loading,
                  onPreviousQuestion: () => _changeQuestion(-1),
                  onNextQuestion: () => _changeQuestion(1),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 選択された表示モードに応じて、本文・設問・解説のコンテンツを切り替えます。
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

  /// 描画完了後に、問題の学習状態と音声を一度だけ初期化します。
  ///
  /// build 中に Provider の状態を更新しないため、Post-frame callback から非同期処理を
  /// 開始します。通常遷移では保存済み進捗を、問題切り替えでは Route の引継ぎ情報を使います。
  void _scheduleInitialization(Question question) {
    // 非同期初期化の多重実行を防ぎ、同じ問題の音声を再読み込みしません。
    if (_initializing || _initializedQuestionId == question.id) return;
    _initializing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final change = widget.questionChange?.questionId == question.id
          ? widget.questionChange
          : null;
      try {
        final detailController = ref.read(
          practiceDetailControllerProvider.notifier,
        );
        final audioController = ref.read(
          audioPlayerControllerProvider.notifier,
        );
        if (change != null) {
          // Route置換を待たせず、旧進捗保存と新問題の状態・音源準備を並行して進めます。
          unawaited(_savePreviousProgress(change));
          await Future.wait([
            detailController.open(question.id, preferredMode: change.mode),
            audioController.loadQuestion(
              question,
              speed: change.speed,
              playbackMode: change.playbackMode,
            ),
          ]);
        } else {
          // 通常遷移では保存済みの表示モードと再生位置を復元します。
          await detailController.open(question.id);
          if (!mounted) return;
          final settings =
              ref.read(settingsControllerProvider).value ?? const AppSettings();
          final progress = await ref
              .read(learningRepositoryProvider)
              .getProgress(question.id);
          if (!mounted) return;
          await audioController.loadQuestion(
            question,
            speed: settings.defaultSpeed,
            restorePosition: settings.rememberPosition
                ? Duration(milliseconds: progress?.lastPositionMs ?? 0)
                : Duration.zero,
          );
        }
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
        if (change != null) {
          final currentPlayer = ref.read(audioPlayerControllerProvider);
          if (currentPlayer.status == AudioPlayerStatus.error) {
            _showMessage(currentPlayer.errorMessage ?? '音声を読み込めませんでした。');
          }
          final detailError = ref
              .read(practiceDetailControllerProvider)
              .errorMessage;
          if (detailError != null) _showMessage(detailError);
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

  /// 切り替え元問題の進捗を保存し、保存失敗時だけ画面上で通知します。
  Future<void> _savePreviousProgress(PracticeQuestionChange change) async {
    try {
      await ref
          .read(practiceDetailControllerProvider.notifier)
          .savePreviousProgress(change);
    } catch (error) {
      if (mounted) _showMessage('学習記録を保存できませんでした。\n$error');
    }
  }

  /// 現在の画面が有効な場合にだけ、ユーザーへ一時的なメッセージを表示します。
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 現在位置から [offset] 問だけ移動するための情報を Controller に要求します。
  ///
  /// 問題切り替え時も現在の速度を保つため、音源が準備済みならプレイヤーの速度を、
  /// そうでなければ設定の既定値を Route 引継ぎ情報へ渡します。
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

  /// 問題選択シートで指定された [questionId] への切り替えを Controller に要求します。
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

  /// 問題の再生完了を再生モードに応じて処理し、必要なら次の問題へ進みます。
  ///
  /// repeatCurrent は同じ問題を再生し、sequential は末尾で停止し、repeatAll は
  /// 末尾から先頭へ戻ります。遷移中の完了通知は無視して競合を防ぎます。
  Future<void> _handlePlaybackCompleted(AudioPlayerState player) async {
    if (!mounted ||
        _automaticAdvanceInProgress ||
        _initializing ||
        player.questionId != widget.questionId) {
      return;
    }

    final detail = ref.read(practiceDetailControllerProvider);
    if (detail.loading || detail.isChangingQuestion) return;
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    if (player.playbackMode == QuestionPlaybackMode.repeatCurrent) {
      // 通常はjust_audioのLoopMode.oneで完結しますが、Platform差によって
      // completedが通知された場合も同じ問題を確実に先頭から再生します。
      await controller.replayCurrentQuestion();
      return;
    }
    if (player.playbackMode == QuestionPlaybackMode.sequential &&
        !detail.hasNextQuestion) {
      // 順次再生の末尾ではcompletedを維持し、ユーザー操作で再開できる状態にします。
      return;
    }
    if (player.playbackMode == QuestionPlaybackMode.repeatAll &&
        detail.questionCount == 1) {
      await controller.replayCurrentQuestion();
      return;
    }

    _automaticAdvanceInProgress = true;
    try {
      final change = await ref
          .read(practiceDetailControllerProvider.notifier)
          .advanceAfterCompletion(
            wrap: player.playbackMode == QuestionPlaybackMode.repeatAll,
            speed: player.speed,
          );
      await _replaceWithQuestion(change, showError: true);
    } finally {
      if (mounted) _automaticAdvanceInProgress = false;
    }
  }

  /// [change] の対象問題へ Route を置換し、戻る操作で旧問題へ戻らないようにします。
  ///
  /// Controller が対象を確定できなかった場合は、必要に応じて保持済みのエラーを表示します。
  Future<void> _replaceWithQuestion(
    PracticeQuestionChange? change, {
    bool showError = true,
  }) async {
    if (!mounted) return;
    if (change == null) {
      final error = ref.read(practiceDetailControllerProvider).errorMessage;
      if (showError && error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    // pushReplacement後に旧Pageのdisposeが新音源を停止しないよう、先に所有権を手放します。
    _routeReplacementInProgress = true;
    context.pushReplacement(
      '/practice/${change.examId}/question/${change.questionId}',
      extra: change,
    );
  }

  /// 同一試験内の問題を選ぶ BottomSheet を開き、選択後に共通の切り替え処理へ渡します。
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

/// 問題モードで設問を単独スクロール表示するコンテンツ Widget。
class _QuestionContent extends StatelessWidget {
  /// 表示する [question] を受け取り、共通の設問セクションを単独表示用に包みます。
  const _QuestionContent({required this.question});

  /// 単独表示する問題データ。
  final Question question;

  /// 設問セクションを余白付きのスクロール可能な領域として構築します。
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
  /// 単独表示と本文併記で共有する設問セクションを構築します。
  const _QuestionSection({required this.question});

  /// 見出し、問題文、選択肢を表示する問題データ。
  final Question question;

  /// 問題種別、問題文、回答選択肢を縦方向に配置します。
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
  /// 解説と、設定に応じた中国語訳を表示するコンテンツを構築します。
  const _ExplanationContent({required this.question});

  /// 解説および正解情報の参照元となる問題データ。
  final Question question;

  /// 解説の有無と中国語表示設定に応じて、適切な説明内容を描画します。
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
  /// 現在の [selected] モードと、選択変更を受け取る [onSelected] を設定します。
  const _ModeSelector({required this.selected, required this.onSelected});

  /// 選択中として強調する内容モード。
  final ContentMode selected;

  /// ユーザーが選んだ内容モードを親 Widget へ通知する callback。
  final ValueChanged<ContentMode> onSelected;

  /// 4 種類の内容モードを切り替えるセレクターを描画します。
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
