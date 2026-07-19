import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/test_models.dart';

/// [TestRepository] を Drift で実装し、テスト履歴を端末へ保存します。
class DriftTestRepository implements TestRepository {
  /// Driftを使用するテスト結果Repositoryを生成します。
  ///
  /// [_database]は呼び出し元が所有するAppDatabaseで、生成時にDB書き込みは行いません。
  DriftTestRepository(this._database);

  /// テストセッションと回答を読み書きするDriftデータベースです。
  final AppDatabase _database;

  @override
  /// 進行中のテストセッションを作成し、採番IDを返します。
  ///
  /// [examId]は対象試験、[startedAtUtc]はUTC開始日時です。
  Future<int> createSession(String examId, DateTime startedAtUtc) {
    return _database
        .into(_database.testSessions)
        .insert(
          TestSessionsCompanion.insert(
            examId: examId,
            status: 'in_progress',
            startedAtUtc: startedAtUtc.millisecondsSinceEpoch,
          ),
        );
  }

  @override
  /// 全回答を採点してセッションと問題別結果をtransactionで保存します。
  ///
  /// [sessionId]は更新対象、[exam]は正解を持つ試験、[answers]は問題IDごとの回答、
  /// [startedAtUtc]は所要時間計算に使用します。採点不能問題があれば例外を送出します。
  Future<TestResult> submitSession({
    required int sessionId,
    required ExamResource exam,
    required Map<String, String?> answers,
    required DateTime startedAtUtc,
  }) async {
    if (exam.questions.any((question) => !question.isGradable)) {
      throw StateError('採点できない問題はテスト結果へ保存できません。');
    }
    final now = DateTime.now().toUtc();
    var correctCount = 0;
    // 問題別回答とセッション集計を同一 transaction で確定し、部分保存を防ぎます。
    await _database.transaction(() async {
      for (final question in exam.questions) {
        final correctOptionId = question.correctOptionId!;
        final selected = answers[question.id];
        // answers にキーがない未回答問題も false として採点します。
        final correct = selected == correctOptionId;
        if (correct) correctCount++;
        await _database
            .into(_database.testSessionAnswers)
            .insertOnConflictUpdate(
              TestSessionAnswersCompanion.insert(
                sessionId: sessionId,
                questionId: question.id,
                selectedOptionId: Value(selected),
                correctOptionId: correctOptionId,
                isCorrect: correct,
              ),
            );
      }
      await (_database.update(
        _database.testSessions,
      )..where((row) => row.id.equals(sessionId))).write(
        TestSessionsCompanion(
          status: const Value('submitted'),
          submittedAtUtc: Value(now.millisecondsSinceEpoch),
          durationMs: Value(now.difference(startedAtUtc).inMilliseconds),
          totalCount: Value(exam.questions.length),
          correctCount: Value(correctCount),
        ),
      );
    });
    return TestResult(
      sessionId: sessionId,
      examId: exam.id,
      totalCount: exam.questions.length,
      correctCount: correctCount,
      durationMs: now.difference(startedAtUtc).inMilliseconds,
      answers: Map.unmodifiable(answers),
    );
  }

  @override
  /// 提出済みの[sessionId]をTestResultとして復元します。
  ///
  /// 存在しない、または進行中のセッションなら`null`を返します。
  Future<TestResult?> getResult(int sessionId) async {
    final sessionQuery = _database.select(_database.testSessions)
      ..where((row) => row.id.equals(sessionId));
    final session = await sessionQuery.getSingleOrNull();
    // 進行中または存在しないセッションを、提出結果として公開しません。
    if (session == null || session.status != 'submitted') return null;
    final answerQuery = _database.select(_database.testSessionAnswers)
      ..where((row) => row.sessionId.equals(sessionId));
    final answers = await answerQuery.get();
    return TestResult(
      sessionId: session.id,
      examId: session.examId,
      totalCount: session.totalCount,
      correctCount: session.correctCount,
      durationMs: session.durationMs,
      answers: {
        for (final answer in answers)
          answer.questionId: answer.selectedOptionId,
      },
    );
  }

  @override
  /// 提出済みセッションの結果一覧を提出日時の新しい順で監視します。
  Stream<List<TestResult>> watchResults() {
    final query = _database.select(_database.testSessions)
      ..where((row) => row.status.equals('submitted'))
      ..orderBy([(row) => OrderingTerm.desc(row.submittedAtUtc)]);
    return query.watch().asyncMap((sessions) async {
      // セッションの更新を起点に、問題別回答を含む domain model へ再構築します。
      final results = <TestResult>[];
      for (final session in sessions) {
        final result = await getResult(session.id);
        if (result != null) results.add(result);
      }
      return results;
    });
  }
}
