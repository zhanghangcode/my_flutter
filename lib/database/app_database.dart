import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

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

class PracticeAnswers extends Table {
  TextColumn get questionId => text()();
  TextColumn get selectedOptionId => text()();
  BoolColumn get isCorrect => boolean()();
  IntColumn get attemptCount => integer().withDefault(const Constant(1))();
  IntColumn get answeredAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}

class FavoriteQuestions extends Table {
  TextColumn get questionId => text()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {questionId};
}

class FavoriteSentences extends Table {
  TextColumn get sentenceId => text()();
  TextColumn get questionId => text()();
  IntColumn get createdAtUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sentenceId};
}

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
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> clearLearningData() => transaction(() async {
    await delete(testSessionAnswers).go();
    await delete(testSessions).go();
    await delete(favoriteSentences).go();
    await delete(favoriteQuestions).go();
    await delete(practiceAnswers).go();
    await delete(practiceProgress).go();
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'nihongo_listening.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
