import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../domain/learning_repository.dart';
import '../domain/practice_models.dart';

/// [LearningRepository] を Drift で実装し、ユーザーの学習状態を端末へ保存します。
class DriftLearningRepository implements LearningRepository {
  /// Driftを使用する学習記録Repositoryを生成します。
  ///
  /// [_database]は呼び出し元が所有するAppDatabaseで、生成時にDB書き込みは行いません。
  DriftLearningRepository(this._database);

  /// 学習記録・お気に入りを読み書きするDriftデータベースです。
  final AppDatabase _database;

  @override
  /// 登録日時の新しい順でお気に入り問題IDを監視します。
  Stream<Set<String>> watchFavoriteQuestionIds() {
    final query = _database.select(_database.favoriteQuestions)
      ..orderBy([(row) => OrderingTerm.desc(row.createdAtUtc)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.questionId).toSet(),
    );
  }

  @override
  /// 登録日時の新しい順でお気に入り文IDを監視します。
  Stream<Set<String>> watchFavoriteSentenceIds() {
    final query = _database.select(_database.favoriteSentences)
      ..orderBy([(row) => OrderingTerm.desc(row.createdAtUtc)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.sentenceId).toSet(),
    );
  }

  @override
  /// 最後の回答が不正解の問題IDを回答日時順で監視します。
  Stream<List<String>> watchWrongQuestionIds() {
    final query = _database.select(_database.practiceAnswers)
      ..where((row) => row.isCorrect.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.answeredAtUtc)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.questionId).toList(),
    );
  }

  @override
  /// 最近開いた問題IDを最終学習日時順で最大20件監視します。
  Stream<List<String>> watchRecentQuestionIds() {
    final query = _database.select(_database.practiceProgress)
      ..orderBy([(row) => OrderingTerm.desc(row.lastPracticedAtUtc)])
      ..limit(20);
    return query.watch().map(
      (rows) => rows.map((row) => row.questionId).toList(),
    );
  }

  @override
  /// [questionId]のお気に入り登録を追加または解除します。
  Future<void> toggleQuestionFavorite(String questionId) async {
    final query = _database.select(_database.favoriteQuestions)
      ..where((row) => row.questionId.equals(questionId));
    final existing = await query.getSingleOrNull();
    // 同じ操作で登録と解除を行い、UI 側に現在状態の分岐を持たせません。
    if (existing == null) {
      await _database
          .into(_database.favoriteQuestions)
          .insert(
            FavoriteQuestionsCompanion.insert(
              questionId: questionId,
              createdAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          );
    } else {
      await (_database.delete(
        _database.favoriteQuestions,
      )..where((row) => row.questionId.equals(questionId))).go();
    }
  }

  @override
  /// [sentenceId]のお気に入り登録を追加または解除します。
  ///
  /// [questionId]は文の所属問題として保存します。
  Future<void> toggleSentenceFavorite(
    String sentenceId,
    String questionId,
  ) async {
    final query = _database.select(_database.favoriteSentences)
      ..where((row) => row.sentenceId.equals(sentenceId));
    final existing = await query.getSingleOrNull();
    if (existing == null) {
      await _database
          .into(_database.favoriteSentences)
          .insert(
            FavoriteSentencesCompanion.insert(
              sentenceId: sentenceId,
              questionId: questionId,
              createdAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          );
    } else {
      await (_database.delete(
        _database.favoriteSentences,
      )..where((row) => row.sentenceId.equals(sentenceId))).go();
    }
  }

  @override
  /// [questionId]の最後の回答を復元します。
  ///
  /// 回答が未保存の場合は`null`を返します。
  Future<AnswerRecord?> getAnswer(String questionId) async {
    final query = _database.select(_database.practiceAnswers)
      ..where((row) => row.questionId.equals(questionId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return AnswerRecord(
      questionId: row.questionId,
      selectedOptionId: row.selectedOptionId,
      isCorrect: row.isCorrect,
      attemptCount: row.attemptCount,
    );
  }

  @override
  /// [questionId]への回答を保存し、試行回数を加算します。
  ///
  /// [optionId]は選択肢ID、[isCorrect]は採点済みの正誤です。
  Future<void> saveAnswer(
    String questionId,
    String optionId,
    bool isCorrect,
  ) async {
    // 最新回答は上書きしつつ、過去の試行回数だけを累積します。
    final previous = await getAnswer(questionId);
    await _database
        .into(_database.practiceAnswers)
        .insertOnConflictUpdate(
          PracticeAnswersCompanion.insert(
            questionId: questionId,
            selectedOptionId: optionId,
            isCorrect: isCorrect,
            attemptCount: Value((previous?.attemptCount ?? 0) + 1),
            answeredAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  /// [questionId]の保存済み進捗を復元します。
  ///
  /// 進捗がない場合は`null`を返します。
  Future<LearningProgress?> getProgress(String questionId) async {
    final query = _database.select(_database.practiceProgress)
      ..where((row) => row.questionId.equals(questionId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return LearningProgress(
      questionId: row.questionId,
      lastPositionMs: row.lastPositionMs,
      lastContentMode: ContentMode.values.firstWhere(
        (mode) => mode.name == row.lastContentMode,
        // 将来モード名が変わっても、本文表示へ安全にフォールバックします。
        orElse: () => ContentMode.transcript,
      ),
      practiceCount: row.practiceCount,
      lastPracticedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.lastPracticedAtUtc,
        isUtc: true,
      ),
    );
  }

  @override
  /// [questionId]を開いた時刻と累計回数を更新します。
  Future<void> markQuestionOpened(String questionId) async {
    // 既存の位置と表示モードを維持したまま、閲覧回数と最終日時を更新します。
    final previous = await getProgress(questionId);
    await _database
        .into(_database.practiceProgress)
        .insertOnConflictUpdate(
          PracticeProgressCompanion.insert(
            questionId: questionId,
            lastPositionMs: Value(previous?.lastPositionMs ?? 0),
            lastContentMode: Value(
              previous?.lastContentMode.name ?? ContentMode.transcript.name,
            ),
            practiceCount: Value((previous?.practiceCount ?? 0) + 1),
            lastPracticedAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  /// [questionId]の位置と表示モードを保存します。
  ///
  /// [positionMs]は問題音声先頭からのmilliseconds、[contentMode]は次回復元する表示モードです。
  Future<void> saveProgress(
    String questionId, {
    required int positionMs,
    required ContentMode contentMode,
  }) async {
    final previous = await getProgress(questionId);
    await _database
        .into(_database.practiceProgress)
        .insertOnConflictUpdate(
          PracticeProgressCompanion.insert(
            questionId: questionId,
            lastPositionMs: Value(positionMs),
            lastContentMode: Value(contentMode.name),
            practiceCount: Value(previous?.practiceCount ?? 1),
            lastPracticedAtUtc: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  /// AppDatabaseへ委譲してすべての学習記録を削除します。
  Future<void> clearAll() => _database.clearLearningData();
}
