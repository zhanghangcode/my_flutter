import '../../practice/domain/practice_models.dart';

/// 提出済みテストの集計値と問題別回答を表すモデル。
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

  /// 問題数が 0 の場合も安全に扱える正答率を返します。
  double get accuracy => totalCount == 0 ? 0 : correctCount / totalCount;
}

/// テストセッションの作成、提出、結果取得を永続化方式から分離する Repository。
abstract interface class TestRepository {
  /// 開始日時を記録した進行中セッションを作成し、採番 ID を返します。
  Future<int> createSession(String examId, DateTime startedAtUtc);

  /// 全問題を採点し、回答と集計結果を一括保存します。
  Future<TestResult> submitSession({
    required int sessionId,
    required ExamResource exam,
    required Map<String, String?> answers,
    required DateTime startedAtUtc,
  });

  /// 指定した提出済みセッションの結果を返します。
  Future<TestResult?> getResult(int sessionId);

  /// 提出済み結果一覧をデータベース更新に追従して配信します。
  Stream<List<TestResult>> watchResults();
}
