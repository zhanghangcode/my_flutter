import 'practice_models.dart';

/// 問題ごとに復元する再生位置と練習状況。
class LearningProgress {
  /// 問題ごとの学習進捗を生成します。
  ///
  /// [lastPositionMs]は問題音声の先頭を基準にしたmilliseconds、[lastPracticedAtUtc]は
  /// UTCの最終学習日時です。生成時に永続化は行いません。
  const LearningProgress({
    required this.questionId,
    required this.lastPositionMs,
    required this.lastContentMode,
    required this.practiceCount,
    required this.lastPracticedAtUtc,
  });

  /// 進捗を保存する問題の一意なID。
  final String questionId;

  /// 最後に再生していた位置。問題音声先頭からのmillisecondsです。
  final int lastPositionMs;

  /// 最後に表示していた練習詳細のContentMode。
  final ContentMode lastContentMode;

  /// 問題を開いた累計回数。
  final int practiceCount;

  /// 最後に問題を開いたUTC日時。
  final DateTime lastPracticedAtUtc;
}

/// 練習モードで最後に提出した回答と回答回数。
class AnswerRecord {
  /// 練習モードの回答記録を生成します。
  ///
  /// [questionId]と[selectedOptionId]は対応する教材・選択肢ID、[isCorrect]は採点結果、
  /// [attemptCount]は同じ問題へ回答した累計回数です。
  const AnswerRecord({
    required this.questionId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.attemptCount,
  });

  /// 回答した問題の一意なID。
  final String questionId;

  /// 利用者が選択した選択肢のID。
  final String selectedOptionId;

  /// 選択肢が教材の正解と一致したかを示します。
  final bool isCorrect;

  /// 同じ問題への累計回答回数。
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
  ///
  /// [questionId]が未登録なら登録し、登録済みなら解除します。
  Future<void> toggleQuestionFavorite(String questionId);

  /// 文のお気に入り登録状態を反転します。
  ///
  /// [sentenceId]で対象文を特定し、[questionId]は一覧から元問題へ戻るために保存します。
  Future<void> toggleSentenceFavorite(String sentenceId, String questionId);

  /// 指定問題の保存済み回答を返します。
  ///
  /// [questionId]の回答が未保存の場合は`null`を返します。
  Future<AnswerRecord?> getAnswer(String questionId);

  /// 回答結果を保存し、回答回数を加算します。
  ///
  /// [optionId]は選択肢ID、[isCorrect]は採点済みの正誤です。
  Future<void> saveAnswer(String questionId, String optionId, bool isCorrect);

  /// 指定問題の保存済み進捗を返します。
  ///
  /// [questionId]の進捗が未保存の場合は`null`を返します。
  Future<LearningProgress?> getProgress(String questionId);

  /// 問題を開いた記録を更新し、練習回数を加算します。
  ///
  /// [questionId]の最終学習日時も現在時刻へ更新します。
  Future<void> markQuestionOpened(String questionId);

  /// 画面を離れる時点の再生位置と表示モードを保存します。
  ///
  /// [positionMs]は問題音声先頭からのmilliseconds、[contentMode]は次回復元する表示モードです。
  Future<void> saveProgress(
    String questionId, {
    required int positionMs,
    required ContentMode contentMode,
  });

  /// 学習履歴、お気に入り、テスト結果をすべて削除します。
  Future<void> clearAll();
}
