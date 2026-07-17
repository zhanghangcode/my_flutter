import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../player/application/audio_player_controller.dart';
import '../domain/learning_repository.dart';
import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// 問題切り替え後のRouteへ引き継ぐ一時的な情報。
class PracticeQuestionChange {
  const PracticeQuestionChange({
    required this.examId,
    required this.questionId,
    required this.mode,
    required this.resumePlayback,
  });

  final String examId;
  final String questionId;
  final ContentMode mode;
  final bool resumePlayback;
}

/// 練習詳細画面で保持する表示モード、選択回答、提出状態。
///
/// 音声の状態は AudioPlayerController が別に管理し、この State は
/// 問題演習に固有の状態だけを担当します。
class PracticeDetailState {
  const PracticeDetailState({
    this.questionId,
    this.mode = ContentMode.transcript,
    this.selectedOptionId,
    this.submitted = false,
    this.savedAnswer,
    this.loading = false,
    this.currentQuestionIndex = -1,
    this.questionCount = 0,
    this.isChangingQuestion = false,
    this.errorMessage,
  });

  final String? questionId;
  final ContentMode mode;
  final String? selectedOptionId;
  final bool submitted;
  final AnswerRecord? savedAnswer;
  final bool loading;
  final int currentQuestionIndex;
  final int questionCount;
  final bool isChangingQuestion;
  final String? errorMessage;

  /// 現在のindexが有効で、前に問題が存在する場合だけtrueを返します。
  bool get hasPreviousQuestion =>
      currentQuestionIndex > 0 && currentQuestionIndex < questionCount;

  /// 現在のindexが有効で、後ろに問題が存在する場合だけtrueを返します。
  bool get hasNextQuestion =>
      currentQuestionIndex >= 0 &&
      currentQuestionIndex < questionCount - 1 &&
      questionCount > 0;

  /// 変更対象だけを置き換えた新しい immutable State を返します。
  PracticeDetailState copyWith({
    String? questionId,
    ContentMode? mode,
    String? selectedOptionId,
    bool clearSelection = false,
    bool? submitted,
    AnswerRecord? savedAnswer,
    bool? loading,
    int? currentQuestionIndex,
    int? questionCount,
    bool? isChangingQuestion,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PracticeDetailState(
      questionId: questionId ?? this.questionId,
      mode: mode ?? this.mode,
      selectedOptionId: clearSelection
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      submitted: submitted ?? this.submitted,
      savedAnswer: savedAnswer ?? this.savedAnswer,
      loading: loading ?? this.loading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questionCount: questionCount ?? this.questionCount,
      isChangingQuestion: isChangingQuestion ?? this.isChangingQuestion,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// 練習詳細の回答操作と学習記録の読み込みを管理する Notifier。
///
/// Widget は ref.watch で [PracticeDetailState] を購読し、操作時のみ ref.read で
/// この Controller を呼び出します。永続化は Repository に委譲します。
class PracticeDetailController extends Notifier<PracticeDetailState> {
  late LearningRepository _learningRepository;
  late PracticeRepository _practiceRepository;
  List<Question> _questions = const [];

  @override
  PracticeDetailState build() {
    // Provider 経由で Repository を受け取り、Controller と Drift を直接結合しません。
    _learningRepository = ref.watch(learningRepositoryProvider);
    _practiceRepository = ref.watch(practiceRepositoryProvider);
    return const PracticeDetailState();
  }

  /// 指定問題の保存済み表示モードと回答を読み込み、閲覧回数を更新します。
  Future<void> open(String questionId, {ContentMode? preferredMode}) async {
    // 同じ問題に対する Widget の再 build で、閲覧回数を重複加算しないようにします。
    if (state.questionId == questionId && !state.loading) return;
    final continuingChange =
        state.questionId == questionId && state.isChangingQuestion;
    state = PracticeDetailState(
      questionId: questionId,
      mode: preferredMode ?? state.mode,
      loading: true,
      currentQuestionIndex: continuingChange ? state.currentQuestionIndex : -1,
      questionCount: continuingChange ? state.questionCount : 0,
      isChangingQuestion: continuingChange,
    );
    try {
      final question = await _practiceRepository.getQuestion(questionId);
      final exam = await _practiceRepository.getExam(question.examId);
      final index = exam.questions.indexWhere((item) => item.id == questionId);
      if (index < 0) {
        throw StateError('問題一覧に対象の問題がありません。');
      }
      _questions = exam.questions;
      final progress = await _learningRepository.getProgress(questionId);
      final answer = await _learningRepository.getAnswer(questionId);
      await _learningRepository.markQuestionOpened(questionId);
      state = PracticeDetailState(
        questionId: questionId,
        mode:
            preferredMode ??
            progress?.lastContentMode ??
            ContentMode.transcript,
        savedAnswer: answer,
        currentQuestionIndex: index,
        questionCount: exam.questions.length,
        isChangingQuestion: continuingChange,
      );
    } catch (error) {
      state = PracticeDetailState(
        questionId: questionId,
        errorMessage: '学習記録を読み込めませんでした。\n$error',
      );
    }
  }

  /// 詳細画面の表示モードを切り替えます。
  void setMode(ContentMode mode) => state = state.copyWith(mode: mode);

  /// 未提出時だけ選択中の回答を更新します。
  void selectOption(String optionId) {
    if (state.submitted) return;
    state = state.copyWith(selectedOptionId: optionId);
  }

  /// 選択回答を採点して保存し、UI を結果表示へ切り替えます。
  Future<void> submit(Question question) async {
    if (!question.isGradable) return;
    final selected = state.selectedOptionId;
    if (selected == null || state.submitted) return;
    final isCorrect = selected == question.correctOptionId;
    await _learningRepository.saveAnswer(question.id, selected, isCorrect);
    final record = await _learningRepository.getAnswer(question.id);
    state = state.copyWith(submitted: true, savedAnswer: record);
  }

  /// 保存済み履歴は維持したまま、画面上の選択と提出状態を初期化します。
  void retry() {
    state = state.copyWith(clearSelection: true, submitted: false);
  }

  /// 現在問題から相対位置にある問題へ切り替える準備を行います。
  Future<PracticeQuestionChange?> changeQuestion(
    int offset, {
    required double speed,
  }) async {
    final targetIndex = state.currentQuestionIndex + offset;
    return _changeToIndex(targetIndex, speed: speed);
  }

  /// 問題Pickerで選択した問題へ、前後ボタンと同じ手順で切り替えます。
  Future<PracticeQuestionChange?> changeToQuestion(
    String questionId, {
    required double speed,
  }) async {
    final targetIndex = _questions.indexWhere(
      (question) => question.id == questionId,
    );
    return _changeToIndex(targetIndex, speed: speed);
  }

  /// 新しい画面の学習状態と音声準備が完了した時点で操作ロックを解除します。
  void completeQuestionChange(String questionId) {
    if (state.questionId != questionId) return;
    state = state.copyWith(isChangingQuestion: false, loading: false);
  }

  Future<PracticeQuestionChange?> _changeToIndex(
    int targetIndex, {
    required double speed,
  }) async {
    if (state.isChangingQuestion ||
        state.loading ||
        state.questionId == null ||
        _questions.isEmpty ||
        targetIndex < 0 ||
        targetIndex >= _questions.length ||
        targetIndex == state.currentQuestionIndex) {
      return null;
    }

    final previousState = state;
    final currentPlayer = ref.read(audioPlayerControllerProvider);
    final resumePlayback = currentPlayer.isPlaying;
    final currentQuestionId = state.questionId!;
    final mode = state.mode;
    final targetQuestion = _questions[targetIndex];
    state = state.copyWith(isChangingQuestion: true, clearError: true);

    try {
      // 切り替え前の再生状態と位置を先に保存し、停止後も正しく引き継げるようにします。
      await _learningRepository.saveProgress(
        currentQuestionId,
        positionMs: currentPlayer.position.inMilliseconds,
        contentMode: mode,
      );
      final audioController = ref.read(audioPlayerControllerProvider.notifier);
      await audioController.stop();

      // 前問題の回答表示を残さず、音源を先頭から読み込む間は操作をロックします。
      state = PracticeDetailState(
        questionId: targetQuestion.id,
        mode: mode,
        loading: true,
        currentQuestionIndex: targetIndex,
        questionCount: _questions.length,
        isChangingQuestion: true,
      );
      await audioController.loadQuestion(targetQuestion, speed: speed);
      final loadedPlayer = ref.read(audioPlayerControllerProvider);
      if (loadedPlayer.questionId != targetQuestion.id ||
          loadedPlayer.status == AudioPlayerStatus.error) {
        throw StateError('切り替え先の音声を読み込めませんでした。');
      }
      return PracticeQuestionChange(
        examId: targetQuestion.examId,
        questionId: targetQuestion.id,
        mode: mode,
        resumePlayback: resumePlayback,
      );
    } catch (error) {
      state = previousState.copyWith(
        isChangingQuestion: false,
        errorMessage: '問題を切り替えられませんでした。\n$error',
      );
      return null;
    }
  }
}

/// 練習詳細の State と操作 API を画面へ公開する Provider。
final practiceDetailControllerProvider =
    NotifierProvider<PracticeDetailController, PracticeDetailState>(
      PracticeDetailController.new,
    );
