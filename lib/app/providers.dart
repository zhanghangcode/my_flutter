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

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => AssetPracticeRepository(),
);

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => DriftLearningRepository(ref.watch(databaseProvider)),
);

final testRepositoryProvider = Provider<TestRepository>(
  (ref) => DriftTestRepository(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPreferencesSettingsRepository(),
);

final examCatalogProvider = FutureProvider<List<ExamSummary>>(
  (ref) => ref.watch(practiceRepositoryProvider).getExams(),
);

final examResourceProvider = FutureProvider.family<ExamResource, String>(
  (ref, id) => ref.watch(practiceRepositoryProvider).getExam(id),
);

final questionProvider = FutureProvider.family<Question, String>(
  (ref, id) => ref.watch(practiceRepositoryProvider).getQuestion(id),
);

final allQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final exams = await ref.watch(examCatalogProvider.future);
  final resources = await Future.wait(
    exams.map((exam) => ref.watch(examResourceProvider(exam.id).future)),
  );
  return resources.expand((resource) => resource.questions).toList();
});

final favoriteQuestionIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchFavoriteQuestionIds(),
);

final favoriteSentenceIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchFavoriteSentenceIds(),
);

final wrongQuestionIdsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchWrongQuestionIds(),
);

final recentQuestionIdsProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchRecentQuestionIds(),
);

final testResultsProvider = StreamProvider<List<TestResult>>(
  (ref) => ref.watch(testRepositoryProvider).watchResults(),
);

class SettingsController extends AsyncNotifier<AppSettings> {
  late SettingsRepository _repository;

  @override
  Future<AppSettings> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.load();
  }

  Future<void> saveChanges(
    AppSettings Function(AppSettings current) change,
  ) async {
    final current = state.value ?? const AppSettings();
    final next = change(current);
    state = AsyncData(next);
    await _repository.save(next);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );
