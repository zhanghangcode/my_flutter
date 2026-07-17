import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// 問題ごとの再生位置、表示モード、練習回数を保存するテーブル。
class PracticeProgress extends Table {
  TextColumn get questionId => text()();
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  TextColumn get lastContentMode =>
      text().withDefault(const Constant('transcript'))();
  IntColumn get practiceCount => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get lastPracticedAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}

/// 練習モードで最後に提出した回答と累計回答回数を保存するテーブル。
class PracticeAnswers extends Table {
  TextColumn get questionId => text()();
  TextColumn get selectedOptionId => text()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get attemptCount => integer().withDefault(const Constant(1))();
  IntColumn get answeredAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}

/// お気に入りに登録した問題 ID を保存するテーブル。
class FavoriteQuestions extends Table {
  TextColumn get questionId => text()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}

/// お気に入りに登録した文と所属問題の ID を保存するテーブル。
class FavoriteSentences extends Table {
  TextColumn get sentenceId => text()();
  TextColumn get questionId => text()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sentenceId};
}

/// テストの開始・提出状態と集計結果を保存するテーブル。
class TestSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get examId => text()();
  TextColumn get status => text()();
  IntColumn get startedAtUtc => integer()();
  IntColumn get submittedAtUtc => integer().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
}

/// テストセッション内の問題別回答を保存するテーブル。
///
/// セッション削除時に回答も削除されるよう、外部キーへ cascade を設定しています。
class TestSessionAnswers extends Table {
  IntColumn get sessionId =>
      integer().references(TestSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get questionId => text()();
  TextColumn get selectedOptionId => text().nullable()();
  TextColumn get correctOptionId => text()();
  BoolColumn get isCorrect => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, questionId};
}

@DriftDatabase(
  tables: [
    PracticeProgress,
    PracticeAnswers,
    FavoriteQuestions,
    FavoriteSentences,
    TestSessions,
    TestSessionAnswers,
  ],
)
/// 学習データを管理する Drift データベース。
///
/// 静的な教材本文は JSON を正として保持し、このデータベースにはユーザー固有の
/// 進捗・回答・お気に入り・テスト結果だけを保存します。
class AppDatabase extends _$AppDatabase {
  /// Application Support 配下の SQLite ファイルを使用する本番用コンストラクタ。
  AppDatabase() : super(_openConnection());

  /// インメモリ DB など任意の QueryExecutor を注入するテスト用コンストラクタ。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
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

// DB の初回利用時までファイルアクセスを遅延し、起動直後の処理を軽くします。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'nihongo_listening.sqlite'));
    // SQLite I/O をバックグラウンド isolate で行い、UI isolate の停止を避けます。
    return NativeDatabase.createInBackground(file);
  });
}
