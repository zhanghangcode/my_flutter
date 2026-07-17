import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/practice/data/asset_practice_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled demo catalog and exam pass validation', () async {
    final repository = AssetPracticeRepository();
    final exams = await repository.getExams();

    expect(exams, hasLength(1));
    final exam = await repository.getExam(exams.single.id);
    expect(exam.questions, hasLength(3));
    expect(exam.questions.first.sentences, isNotEmpty);
    expect(
      exam.questions.first.options.any(
        (option) => option.id == exam.questions.first.correctOptionId,
      ),
      isTrue,
    );
  });
}
