import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/test_models.dart';

class DriftTestRepository implements TestRepository {
  DriftTestRepository(this._database);

  final AppDatabase _database;

  @override
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
  Future<TestResult> submitSession({
    required int sessionId,
    required ExamResource exam,
    required Map<String, String?> answers,
    required DateTime startedAtUtc,
  }) async {
    final now = DateTime.now().toUtc();
    var correctCount = 0;
    await _database.transaction(() async {
      for (final question in exam.questions) {
        final selected = answers[question.id];
        final correct = selected == question.correctOptionId;
        if (correct) correctCount++;
        await _database
            .into(_database.testSessionAnswers)
            .insertOnConflictUpdate(
              TestSessionAnswersCompanion.insert(
                sessionId: sessionId,
                questionId: question.id,
                selectedOptionId: Value(selected),
                correctOptionId: question.correctOptionId,
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
  Future<TestResult?> getResult(int sessionId) async {
    final sessionQuery = _database.select(_database.testSessions)
      ..where((row) => row.id.equals(sessionId));
    final session = await sessionQuery.getSingleOrNull();
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
  Stream<List<TestResult>> watchResults() {
    final query = _database.select(_database.testSessions)
      ..where((row) => row.status.equals('submitted'))
      ..orderBy([(row) => OrderingTerm.desc(row.submittedAtUtc)]);
    return query.watch().asyncMap((sessions) async {
      final results = <TestResult>[];
      for (final session in sessions) {
        final result = await getResult(session.id);
        if (result != null) results.add(result);
      }
      return results;
    });
  }
}
