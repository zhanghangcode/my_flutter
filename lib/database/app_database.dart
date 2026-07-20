import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// 問題ごとの再生位置、表示モード、練習回数を保存するテーブル。
class PracticeProgress extends Table {
  /// 進捗の所属先となる問題IDです。主キーとして一意に保存します。
  TextColumn get questionId => text()();

  /// 最後の再生位置。問題音声先頭からのmillisecondsです。
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();

  /// 最後に表示していたContentModeの文字列表現です。
  TextColumn get lastContentMode =>
      text().withDefault(const Constant('transcript'))();

  /// この問題を開いた累計回数です。
  IntColumn get practiceCount => integer().withDefault(const Constant(0))();

  /// 練習を完了として扱うかを示すフラグです。
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// 最後に練習したUTC時刻をUnix millisecondsで保存します。
  IntColumn get lastPracticedAtUtc => integer()();

  @override
  /// 問題ごとに1行だけ進捗を保存する主キーを返します。
  Set<Column<Object>> get primaryKey => {questionId};
}

/// 練習モードで最後に提出した回答と累計回答回数を保存するテーブル。
class PracticeAnswers extends Table {
  /// 回答の所属先となる問題IDです。主キーとして一意に保存します。
  TextColumn get questionId => text()();

  /// 最後に選択した選択肢IDです。
  TextColumn get selectedOptionId => text()();

  /// 最後の回答が正解だったかを示します。
  BoolColumn get isCorrect => boolean()();

  /// 同じ問題へ回答した累計回数です。
  IntColumn get attemptCount => integer().withDefault(const Constant(1))();

  /// 最後に回答したUTC時刻をUnix millisecondsで保存します。
  IntColumn get answeredAtUtc => integer()();

  @override
  /// 問題ごとに1行だけ回答を保存する主キーを返します。
  Set<Column<Object>> get primaryKey => {questionId};
}

/// お気に入りに登録した問題 ID を保存するテーブル。
class FavoriteQuestions extends Table {
  /// お気に入りに登録した問題IDです。主キーとして一意に保存します。
  TextColumn get questionId => text()();

  /// お気に入りに登録したUTC時刻をUnix millisecondsで保存します。
  IntColumn get createdAtUtc => integer()();

  @override
  /// 問題IDを主キーとして返します。
  Set<Column<Object>> get primaryKey => {questionId};
}

/// お気に入りに登録した文と所属問題の ID を保存するテーブル。
class FavoriteSentences extends Table {
  /// お気に入りに登録した文の一意なIDです。
  TextColumn get sentenceId => text()();

  /// 文が属する問題の一意なIDです。
  TextColumn get questionId => text()();

  /// お気に入りに登録したUTC時刻をUnix millisecondsで保存します。
  IntColumn get createdAtUtc => integer()();

  @override
  /// 文IDを主キーとして返します。
  Set<Column<Object>> get primaryKey => {sentenceId};
}

/// テストの開始・提出状態と集計結果を保存するテーブル。
class TestSessions extends Table {
  /// Driftが自動採番するテストセッションIDです。
  IntColumn get id => integer().autoIncrement()();

  /// テスト対象となる試験の一意なIDです。
  TextColumn get examId => text()();

  /// 進行中・提出済みなどを表すセッション状態の文字列です。
  TextColumn get status => text()();

  /// テスト開始UTC時刻をUnix millisecondsで保存します。
  IntColumn get startedAtUtc => integer()();

  /// 提出UTC時刻をUnix millisecondsで保存します。未提出時は`null`です。
  IntColumn get submittedAtUtc => integer().nullable()();

  /// テスト開始から提出までのmillisecondsです。
  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  /// 採点対象の問題数です。
  IntColumn get totalCount => integer().withDefault(const Constant(0))();

  /// 正答した問題数です。
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
}

/// テストセッション内の問題別回答を保存するテーブル。
///
/// セッション削除時に回答も削除されるよう、外部キーへ cascade を設定しています。
class TestSessionAnswers extends Table {
  /// 所属するテストセッションIDです。親セッション削除時にcascade削除されます。
  IntColumn get sessionId =>
      integer().references(TestSessions, #id, onDelete: KeyAction.cascade)();

  /// 回答対象となる問題の一意なIDです。
  TextColumn get questionId => text()();

  /// 利用者が選択した選択肢IDです。未回答時は`null`です。
  TextColumn get selectedOptionId => text().nullable()();

  /// 提出時点の正解選択肢IDを保存したスナップショットです。
  TextColumn get correctOptionId => text()();

  /// 選択肢が正解と一致したかを示します。
  BoolColumn get isCorrect => boolean()();

  @override
  /// セッションと問題の組み合わせを一意にする複合主キーを返します。
  Set<Column<Object>> get primaryKey => {sessionId, questionId};
}

/// 試験単位で端末へ保存した音声のLocal Manifestを保持するテーブル。
class ExamDownloads extends Table {
  /// ダウンロード対象となる試験IDです。
  TextColumn get examId => text()();

  /// `downloaded`または`failed`の保存状態です。
  TextColumn get status => text()();

  /// 全音声の検証が完了したUTC時刻です。失敗時は`null`です。
  IntColumn get downloadedAtUtc => integer().nullable()();

  /// Application Support Directoryを基準とする保存先の相対pathです。
  TextColumn get localDirectory => text().nullable()();

  /// 保存した音声リソースのversionです。
  IntColumn get resourceVersion => integer()();

  /// 検証済みの問題別音声ファイル数です。
  IntColumn get audioFileCount => integer()();

  @override
  /// 試験ごとに1件だけManifestを保持する主キーを返します。
  Set<Column<Object>> get primaryKey => {examId};
}

@DriftDatabase(
  tables: [
    PracticeProgress,
    PracticeAnswers,
    FavoriteQuestions,
    FavoriteSentences,
    TestSessions,
    TestSessionAnswers,
    ExamDownloads,
  ],
)
/// 学習データを管理する Drift データベース。
///
/// 静的な教材本文は JSON を正として保持し、このデータベースにはユーザー固有の
/// 進捗・回答・お気に入り・テスト結果と、音声のLocal Manifestを保存します。
class AppDatabase extends _$AppDatabase {
  /// Application Support 配下の SQLite ファイルを使用する本番用コンストラクタ。
  AppDatabase() : super(_openConnection());

  /// インメモリ DB など任意の QueryExecutor を注入するテスト用コンストラクタ。
  AppDatabase.forTesting(super.executor);

  @override
  /// 現在のDrift schema versionを返します。
  int get schemaVersion => 2;

  @override
  /// 新規DB作成時と接続開始時の移行処理を返します。
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // V1の学習データを維持したまま、音声Manifest用テーブルだけを追加します。
        await migrator.createTable(examDownloads);
      }
    },
    beforeOpen: (details) async {
      // TestSessionAnswers の cascade 削除をすべての接続で有効にします。
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// すべてのユーザー学習データを一つの transaction で削除します。
  ///
  /// transaction にまとめることで、途中失敗時に一部だけ消える状態を防ぎます。
  Future<void> clearLearningData() => transaction(() async {
    await delete(testSessionAnswers).go();
    await delete(testSessions).go();
    await delete(favoriteSentences).go();
    await delete(favoriteQuestions).go();
    await delete(practiceAnswers).go();
    await delete(practiceProgress).go();
  });
}

/// DBの初回利用時までファイルアクセスを遅延するLazyDatabaseを生成します。
///
/// Application Support配下のSQLiteファイルをバックグラウンドisolateで開き、UI isolateの
/// 起動直後の負荷を抑えます。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'nihongo_listening.sqlite'));
    // SQLite I/O をバックグラウンド isolate で行い、UI isolate の停止を避けます。
    return NativeDatabase.createInBackground(file);
  });
}
