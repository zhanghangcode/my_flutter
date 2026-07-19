import '../../practice/domain/practice_models.dart';

/// 提出済みテストの集計値と問題別回答を表すモデル。
class TestResult {
  /// 提出済みテストの集計結果を生成します。
  ///
  /// [sessionId]はDriftのセッションID、[examId]は採点対象の試験IDです。[durationMs]は
  /// 開始から提出までのmilliseconds、[answers]は問題IDをキーとする選択肢IDです。
  /// 未回答はMapの値を`null`として保持します。
  const TestResult({
    required this.sessionId,
    required this.examId,
    required this.totalCount,
    required this.correctCount,
    required this.durationMs,
    required this.answers,
  });

  /// Driftに保存されたテストセッションのID。
  final int sessionId;

  /// この結果が属する試験の一意なID。
  final String examId;

  /// 採点対象となった問題数。
  final int totalCount;

  /// 正答した問題数。
  final int correctCount;

  /// テスト開始から提出までのmilliseconds。
  final int durationMs;

  /// 問題IDをキーとする回答Map。未回答の値は`null`です。
  final Map<String, String?> answers;

  /// 問題数が 0 の場合も安全に扱える正答率を返します。
  double get accuracy => totalCount == 0 ? 0 : correctCount / totalCount;
}

/// テストセッションの作成、提出、結果取得を永続化方式から分離する Repository。
abstract interface class TestRepository {
  /// 開始日時を記録した進行中セッションを作成し、採番IDを返します。
  ///
  /// [examId]は対象試験、[startedAtUtc]はUTCの開始日時です。
  Future<int> createSession(String examId, DateTime startedAtUtc);

  /// 全問題を採点し、回答と集計結果を一括保存します。
  ///
  /// [sessionId]は更新対象、[exam]は正解を含む教材、[answers]は問題IDごとの回答、
  /// [startedAtUtc]は所要時間計算に使うUTC開始日時です。
  Future<TestResult> submitSession({
    required int sessionId,
    required ExamResource exam,
    required Map<String, String?> answers,
    required DateTime startedAtUtc,
  });

  /// 指定した提出済みセッションの結果を返します。
  ///
  /// [sessionId]が未提出または存在しない場合は`null`を返します。
  Future<TestResult?> getResult(int sessionId);

  /// 提出済み結果一覧をデータベース更新に追従して配信します。
  Stream<List<TestResult>> watchResults();
}
