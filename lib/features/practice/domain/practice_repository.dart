import 'practice_models.dart';

/// 静的な教材データの取得方法を UI とデータソースから分離する Repository。
abstract interface class PracticeRepository {
  /// 利用可能な試験の一覧を返します。
  Future<List<ExamSummary>> getExams();

  /// 指定した試験 ID の全問題を返します。
  Future<ExamResource> getExam(String examId);

  /// 全教材から指定した問題 ID を検索して返します。
  Future<Question> getQuestion(String questionId);

  /// 現在問題から相対位置にある問題を返し、範囲外では null を返します。
  Future<Question?> getAdjacentQuestion(String questionId, int offset);
}

/// 教材 JSON の形式または参照関係が不正な場合に通知する例外。
class ContentValidationException implements Exception {
  const ContentValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
