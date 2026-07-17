import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/test/data/drift_test_repository.dart';

void main() {
  late AppDatabase database;
  late DriftTestRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftTestRepository(database);
  });

  tearDown(() => database.close());

  test('unanswered questions count as incorrect', () async {
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
    const exam = ExamResource(id: 'exam', titleJa: '試験', questions: [question]);
    final started = DateTime.now().toUtc();
    final id = await repository.createSession(exam.id, started);

    final result = await repository.submitSession(
      sessionId: id,
      exam: exam,
      answers: const {},
      startedAtUtc: started,
    );

    expect(result.totalCount, 1);
    expect(result.correctCount, 0);
    expect(result.answers['q1'], isNull);
    expect((await repository.getResult(id))?.correctCount, 0);
  });
}
