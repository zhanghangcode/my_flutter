import 'practice_models.dart';

abstract interface class PracticeRepository {
  Future<List<ExamSummary>> getExams();

  Future<ExamResource> getExam(String examId);

  Future<Question> getQuestion(String questionId);

  Future<Question?> getAdjacentQuestion(String questionId, int offset);
}

class ContentValidationException implements Exception {
  const ContentValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
