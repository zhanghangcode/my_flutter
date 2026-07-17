import 'practice_models.dart';

/// 問題ごとに復元する再生位置と練習状況。
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

/// 練習モードで最後に提出した回答と回答回数。
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

/// 学習履歴とお気に入りの永続化 API。
///
/// 監視系 API は Stream を返し、Drift の更新を Riverpod と UI へ即時反映します。
abstract interface class LearningRepository {
  /// お気に入りに登録されている問題 ID の集合を監視します。
  Stream<Set<String>> watchFavoriteQuestionIds();

  /// お気に入りに登録されている文 ID の集合を監視します。
  Stream<Set<String>> watchFavoriteSentenceIds();

  /// 最新回答が不正解の問題 ID を回答日時順で監視します。
  Stream<List<String>> watchWrongQuestionIds();

  /// 最近開いた問題 ID を最終学習日時順で監視します。
  Stream<List<String>> watchRecentQuestionIds();

  /// 問題のお気に入り登録状態を反転します。
  Future<void> toggleQuestionFavorite(String questionId);

  /// 文のお気に入り登録状態を反転します。
  Future<void> toggleSentenceFavorite(String sentenceId, String questionId);

  /// 指定問題の保存済み回答を返します。
  Future<AnswerRecord?> getAnswer(String questionId);

  /// 回答結果を保存し、回答回数を加算します。
  Future<void> saveAnswer(String questionId, String optionId, bool isCorrect);

  /// 指定問題の保存済み進捗を返します。
  Future<LearningProgress?> getProgress(String questionId);

  /// 問題を開いた記録を更新し、練習回数を加算します。
  Future<void> markQuestionOpened(String questionId);

  /// 画面を離れる時点の再生位置と表示モードを保存します。
  Future<void> saveProgress(
    String questionId, {
    required int positionMs,
    required ContentMode contentMode,
  });

  /// 学習履歴、お気に入り、テスト結果をすべて削除します。
  Future<void> clearAll();
}
