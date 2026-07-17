import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../features/practice/data/asset_practice_repository.dart';
import '../features/practice/data/drift_learning_repository.dart';
import '../features/practice/domain/learning_repository.dart';
import '../features/practice/domain/practice_models.dart';
import '../features/practice/domain/practice_repository.dart';
import '../features/settings/data/shared_preferences_settings_repository.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/test/data/drift_test_repository.dart';
import '../features/test/domain/test_models.dart';

/// アプリで共有する Drift データベースを提供する Provider。
///
/// Provider の破棄時に接続も閉じ、データベースのライフサイクルを Riverpod に委ねます。
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Bundle 内の JSON 教材へアクセスする Repository を提供します。
final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => AssetPracticeRepository(),
);

/// 学習履歴とお気に入りを Drift へ保存する Repository を提供します。
final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => DriftLearningRepository(ref.watch(databaseProvider)),
);

/// テストセッションと採点結果を Drift へ保存する Repository を提供します。
final testRepositoryProvider = Provider<TestRepository>(
  (ref) => DriftTestRepository(ref.watch(databaseProvider)),
);

/// 軽量なアプリ設定を SharedPreferences へ保存する Repository を提供します。
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPreferencesSettingsRepository(),
);

/// 教材一覧を非同期で読み込み、loading・data・error を UI へ公開します。
final examCatalogProvider = FutureProvider<List<ExamSummary>>(
  (ref) => ref.watch(practiceRepositoryProvider).getExams(),
);

/// examId ごとの試験データを必要な画面だけで読み込む family Provider。
final examResourceProvider = FutureProvider.family<ExamResource, String>(
  (ref, id) => ref.watch(practiceRepositoryProvider).getExam(id),
);

/// questionId ごとの問題を解決する family Provider。
final questionProvider = FutureProvider.family<Question, String>(
  (ref, id) => ref.watch(practiceRepositoryProvider).getQuestion(id),
);

/// お気に入り・履歴画面で ID と教材を関連付けるため、全問題を平坦化して提供します。
final allQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  // ref.watch により、参照元の教材 Provider が更新された場合も結果を再計算します。
  final exams = await ref.watch(examCatalogProvider.future);
  final resources = await Future.wait(
    exams.map((exam) => ref.watch(examResourceProvider(exam.id).future)),
  );
  return resources.expand((resource) => resource.questions).toList();
});

/// お気に入りに登録した問題 ID を Drift の変更に追従して配信します。
final favoriteQuestionIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchFavoriteQuestionIds(),
);

/// お気に入りに登録した文 ID を Drift の変更に追従して配信します。
final favoriteSentenceIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchFavoriteSentenceIds(),
);

/// 最新の回答が不正解だった問題 ID を配信します。
final wrongQuestionIdsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchWrongQuestionIds(),
);

/// 直近に開いた問題 ID を最終学習日時順で配信します。
final recentQuestionIdsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchRecentQuestionIds(),
);

/// 提出済みテスト結果を保存日時順で配信します。
final testResultsProvider = StreamProvider<List<TestResult>>(
  (ref) => ref.watch(testRepositoryProvider).watchResults(),
);

/// 設定の読み込みと更新を管理する AsyncNotifier。
///
/// UI は ref.watch で現在値を購読し、ユーザー操作時だけ ref.read で
/// [saveChanges] を呼び出すことで、表示更新と永続化を分離します。
class SettingsController extends AsyncNotifier<AppSettings> {
  late SettingsRepository _repository;

  @override
  Future<AppSettings> build() async {
    // Repository の差し替えを Provider 経由にすることで、テスト可能性を保ちます。
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.load();
  }

  /// 現在値へ変更関数を適用し、UI 更新後に永続ストレージへ保存します。
  Future<void> saveChanges(
    AppSettings Function(AppSettings current) change,
  ) async {
    final current = state.value ?? const AppSettings();
    final next = change(current);
    state = AsyncData(next);
    await _repository.save(next);
  }
}

/// [SettingsController] の State と操作 API を Widget ツリーへ公開します。
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );
