import 'practice_models.dart';

/// 静的な教材データの取得方法を UI とデータソースから分離する Repository。
abstract interface class PracticeRepository {
  /// 利用可能な試験の一覧を非同期で返します。
  Future<List<ExamSummary>> getExams();

  /// 指定した試験IDの全問題を非同期で返します。
  ///
  /// [examId]が存在しない、または教材JSONが不正な場合は実装側の例外を送出します。
  Future<ExamResource> getExam(String examId);

  /// 全教材から指定した問題IDを検索して返します。
  ///
  /// [questionId]が見つからない場合は実装側の例外を送出します。
  Future<Question> getQuestion(String questionId);

  /// 現在問題から相対位置にある問題を返します。
  ///
  /// [offset]は正なら次、負なら前への移動数です。範囲外または[questionId]が不明な場合は
  /// `null`を返します。
  Future<Question?> getAdjacentQuestion(String questionId, int offset);
}

/// 教材 JSON の形式または参照関係が不正な場合に通知する例外。
class ContentValidationException implements Exception {
  /// 教材検証エラーを生成します。
  ///
  /// [message]には問題IDやAsset pathを含む、開発者向けの原因を指定します。
  const ContentValidationException(this.message);

  /// 利用者へ表示できる教材検証失敗の内容。
  final String message;

  @override
  /// 例外メッセージを文字列として返します。
  String toString() => message;
}
