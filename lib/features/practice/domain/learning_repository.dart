import 'practice_models.dart';

class LearningProgress {
  const LearningProgress({
    required this.questionId,
    required this.lastPositionMs,
    required this.lastContentMode,
    required this.practiceCount,
    required this.lastPracticedAtUtc,
  });

  final String questionId;
  final int lastPositionMs;
  final ContentMode lastContentMode;
  final int practiceCount;
  final DateTime lastPracticedAtUtc;
}

class AnswerRecord {
  const AnswerRecord({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.attemptCount,
  });

  final String questionId;
  final String selectedOptionId;
  final bool isCorrect;
  final int attemptCount;
}

abstract interface class LearningRepository {
  Stream<Set<String>> watchFavoriteQuestionIds();

  Stream<Set<String>> watchFavoriteSentenceIds();

  Stream<List<String>> watchWrongQuestionIds();

  Stream<List<String>> watchRecentQuestionIds();

  Future<void> toggleQuestionFavorite(String questionId);

  Future<void> toggleSentenceFavorite(String sentenceId, String questionId);

  Future<AnswerRecord?> getAnswer(String questionId);

  Future<void> saveAnswer(String questionId, String optionId, bool isCorrect);

  Future<LearningProgress?> getProgress(String questionId);

  Future<void> markQuestionOpened(String questionId);

  Future<void> saveProgress(
    String questionId, {
    required int positionMs,
    required ContentMode contentMode,
  });

  Future<void> clearAll();
}
