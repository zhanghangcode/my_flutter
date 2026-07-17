import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/learning_repository.dart';
import '../domain/practice_models.dart';

class PracticeDetailState {
  const PracticeDetailState({
    this.questionId,
    this.mode = ContentMode.transcript,
    this.selectedOptionId,
    this.submitted = false,
    this.savedAnswer,
    this.loading = false,
    this.errorMessage,
  });

  final String? questionId;
  final ContentMode mode;
  final String? selectedOptionId;
  final bool submitted;
  final AnswerRecord? savedAnswer;
  final bool loading;
  final String? errorMessage;

  PracticeDetailState copyWith({
    String? questionId,
    ContentMode? mode,
    String? selectedOptionId,
    bool clearSelection = false,
    bool? submitted,
    AnswerRecord? savedAnswer,
    bool? loading,
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
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PracticeDetailController extends Notifier<PracticeDetailState> {
  late LearningRepository _repository;

  @override
  PracticeDetailState build() {
    _repository = ref.watch(learningRepositoryProvider);
    return const PracticeDetailState();
  }

  Future<void> open(String questionId) async {
    if (state.questionId == questionId) return;
    state = PracticeDetailState(questionId: questionId, loading: true);
    try {
      final progress = await _repository.getProgress(questionId);
      final answer = await _repository.getAnswer(questionId);
      await _repository.markQuestionOpened(questionId);
      state = PracticeDetailState(
        questionId: questionId,
        mode: progress?.lastContentMode ?? ContentMode.transcript,
        savedAnswer: answer,
      );
    } catch (error) {
      state = PracticeDetailState(
        questionId: questionId,
        errorMessage: '学習記録を読み込めませんでした。\n$error',
      );
    }
  }

  void setMode(ContentMode mode) => state = state.copyWith(mode: mode);

  void selectOption(String optionId) {
    if (state.submitted) return;
    state = state.copyWith(selectedOptionId: optionId);
  }

  Future<void> submit(Question question) async {
    final selected = state.selectedOptionId;
    if (selected == null || state.submitted) return;
    final isCorrect = selected == question.correctOptionId;
    await _repository.saveAnswer(question.id, selected, isCorrect);
    final record = await _repository.getAnswer(question.id);
    state = state.copyWith(submitted: true, savedAnswer: record);
  }

  void retry() {
    state = state.copyWith(clearSelection: true, submitted: false);
  }
}

final practiceDetailControllerProvider =
    NotifierProvider<PracticeDetailController, PracticeDetailState>(
      PracticeDetailController.new,
    );
