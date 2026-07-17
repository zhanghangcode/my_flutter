import '../../practice/domain/practice_models.dart';

class TestResult {
  const TestResult({
    required this.sessionId,
    required this.examId,
    required this.totalCount,
    required this.correctCount,
    required this.durationMs,
    required this.answers,
  });

  final int sessionId;
  final String examId;
  final int totalCount;
  final int correctCount;
  final int durationMs;
  final Map<String, String?> answers;

  double get accuracy => totalCount == 0 ? 0 : correctCount / totalCount;
}

abstract interface class TestRepository {
  Future<int> createSession(String examId, DateTime startedAtUtc);

  Future<TestResult> submitSession({
    required int sessionId,
    required ExamResource exam,
    required Map<String, String?> answers,
    required DateTime startedAtUtc,
  });

  Future<TestResult?> getResult(int sessionId);

  Stream<List<TestResult>> watchResults();
}
