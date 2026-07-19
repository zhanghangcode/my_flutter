import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/practice/data/drift_learning_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

/// DriftLearningRepository の永続化規則をインメモリ DB で検証するテスト群です。
void main() {
  late AppDatabase database;
  late DriftLearningRepository repository;

  setUp(() {
    // Given: テスト間でデータを共有しないインメモリ Drift DB を用意します。
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftLearningRepository(database);
  });

  // 各テスト後に DB を閉じ、購読とネイティブリソースを解放します。
  tearDown(() => database.close());

  test('favorites are idempotently toggled', () async {
    // When / Then: 1 回目で登録され、同じ操作の 2 回目で解除されることを確認します。
    await repository.toggleQuestionFavorite('q1');
    expect(await repository.watchFavoriteQuestionIds().first, {'q1'});

    await repository.toggleQuestionFavorite('q1');
    expect(await repository.watchFavoriteQuestionIds().first, isEmpty);
  });

  test('answer attempts and progress are persisted', () async {
    // When: 同じ問題へ 2 回回答し、表示モードを含む進捗を保存します。
    await repository.saveAnswer('q1', 'a', false);
    await repository.saveAnswer('q1', 'b', true);
    final answer = await repository.getAnswer('q1');

    // Then: 最新回答と累計回数が上書き・加算規則どおりに復元されます。
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

    // Then: 再生位置、表示モード、閲覧回数が同じ問題 ID で保持されます。
    expect(progress?.lastPositionMs, 1234);
    expect(progress?.lastContentMode, ContentMode.combined);
    expect(progress?.practiceCount, 1);
  });

  test('clear removes all learning state', () async {
    // Given: 削除対象となる各種学習データを保存します。
    await repository.toggleQuestionFavorite('q1');
    await repository.toggleSentenceFavorite('s1', 'q1');
    await repository.saveAnswer('q1', 'a', false);
    await repository.markQuestionOpened('q1');

    // When: 学習データの一括削除を実行します。
    await repository.clearAll();

    // Then: 各問い合わせが空または null を返します。
    expect(await repository.watchFavoriteQuestionIds().first, isEmpty);
    expect(await repository.watchFavoriteSentenceIds().first, isEmpty);
    expect(await repository.getAnswer('q1'), isNull);
    expect(await repository.getProgress('q1'), isNull);
  });
}
