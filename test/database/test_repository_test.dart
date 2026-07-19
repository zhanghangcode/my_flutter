import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/test/data/drift_test_repository.dart';

/// DriftTestRepository の採点とテスト結果保存を検証するテスト群です。
void main() {
  late AppDatabase database;
  late DriftTestRepository repository;

  setUp(() {
    // Given: セッションと回答を隔離できるインメモリ Drift DB を用意します。
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTestRepository(database);
  });

  // テスト終了ごとに DB 接続を閉じます。
  tearDown(() => database.close());

  test('unanswered questions count as incorrect', () async {
    // Given: 正解が b の 1 問だけを含む試験を用意します。
    const question = Question(
      id: 'q1',
      examId: 'exam',
      section: 1,
      number: 1,
      type: 'demo',
      promptJa: '質問',
      options: [
        AnswerOption(id: 'a', label: 1, textJa: 'A'),
        AnswerOption(id: 'b', label: 2, textJa: 'B'),
      ],
      correctOptionId: 'b',
      audioAssetPath: 'audio.wav',
      sentences: [],
      explanation: QuestionExplanation(ja: '説明', zh: '说明'),
    );
    const exam = ExamResource(
      schemaVersion: 2,
      id: 'exam',
      titleJa: '試験',
      questions: [question],
    );
    final started = DateTime.now().toUtc();
    final id = await repository.createSession(exam.id, started);

    // When: 回答 Map を空のままセッションを提出します。
    final result = await repository.submitSession(
      sessionId: id,
      exam: exam,
      answers: const {},
      startedAtUtc: started,
    );

    // Then: 未回答は不正解として集計・保存され、回答値は null になります。
    expect(result.totalCount, 1);
    expect(result.correctCount, 0);
    expect(result.answers['q1'], isNull);
    expect((await repository.getResult(id))?.correctCount, 0);
  });
}
