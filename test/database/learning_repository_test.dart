import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/practice/data/drift_learning_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

void main() {
  late AppDatabase database;
  late DriftLearningRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftLearningRepository(database);
  });

  tearDown(() => database.close());

  test('favorites are idempotently toggled', () async {
    await repository.toggleQuestionFavorite('q1');
    expect(await repository.watchFavoriteQuestionIds().first, {'q1'});

    await repository.toggleQuestionFavorite('q1');
    expect(await repository.watchFavoriteQuestionIds().first, isEmpty);
  });

  test('answer attempts and progress are persisted', () async {
    await repository.saveAnswer('q1', 'a', false);
    await repository.saveAnswer('q1', 'b', true);
    final answer = await repository.getAnswer('q1');
    expect(answer?.selectedOptionId, 'b');
    expect(answer?.attemptCount, 2);
    expect(answer?.isCorrect, isTrue);

    await repository.markQuestionOpened('q1');
    await repository.saveProgress(
      'q1',
      positionMs: 1234,
      contentMode: ContentMode.combined,
    );
    final progress = await repository.getProgress('q1');
    expect(progress?.lastPositionMs, 1234);
    expect(progress?.lastContentMode, ContentMode.combined);
    expect(progress?.practiceCount, 1);
  });

  test('clear removes all learning state', () async {
    await repository.toggleQuestionFavorite('q1');
    await repository.toggleSentenceFavorite('s1', 'q1');
    await repository.saveAnswer('q1', 'a', false);
    await repository.markQuestionOpened('q1');

    await repository.clearAll();

    expect(await repository.watchFavoriteQuestionIds().first, isEmpty);
    expect(await repository.watchFavoriteSentenceIds().first, isEmpty);
    expect(await repository.getAnswer('q1'), isNull);
    expect(await repository.getProgress('q1'), isNull);
  });
}
