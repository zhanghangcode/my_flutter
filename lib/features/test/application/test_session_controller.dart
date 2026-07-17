import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../player/application/audio_player_controller.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/test_models.dart';

class TestSessionState {
  const TestSessionState({
    required this.sessionId,
    required this.exam,
    required this.startedAtUtc,
    this.currentIndex = 0,
    this.answers = const {},
    this.playedQuestionIds = const {},
  });

  final int sessionId;
  final ExamResource exam;
  final DateTime startedAtUtc;
  final int currentIndex;
  final Map<String, String?> answers;
  final Set<String> playedQuestionIds;

  Question get currentQuestion => exam.questions[currentIndex];

  TestSessionState copyWith({
    int? currentIndex,
    Map<String, String?>? answers,
    Set<String>? playedQuestionIds,
  }) {
    return TestSessionState(
      sessionId: sessionId,
      exam: exam,
      startedAtUtc: startedAtUtc,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      playedQuestionIds: playedQuestionIds ?? this.playedQuestionIds,
    );
  }
}

class TestSessionController extends AsyncNotifier<TestSessionState?> {
  @override
  Future<TestSessionState?> build() async => null;

  Future<void> start(String examId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final exam = await ref.read(practiceRepositoryProvider).getExam(examId);
      if (exam.questions.isEmpty) throw StateError('問題がありません。');
      final started = DateTime.now().toUtc();
      final sessionId = await ref
          .read(testRepositoryProvider)
          .createSession(examId, started);
      final session = TestSessionState(
        sessionId: sessionId,
        exam: exam,
        startedAtUtc: started,
      );
      await _loadAudio(session.currentQuestion);
      return session.copyWith(playedQuestionIds: {session.currentQuestion.id});
    });
  }

  void select(String optionId) {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(
      session.copyWith(
        answers: {...session.answers, session.currentQuestion.id: optionId},
      ),
    );
  }

  Future<void> goTo(int index) async {
    final session = state.value;
    if (session == null ||
        index < 0 ||
        index >= session.exam.questions.length) {
      return;
    }
    await ref.read(audioPlayerControllerProvider.notifier).stop();
    var next = session.copyWith(currentIndex: index);
    final question = next.currentQuestion;
    if (!next.playedQuestionIds.contains(question.id)) {
      await _loadAudio(question);
      next = next.copyWith(
        playedQuestionIds: {...next.playedQuestionIds, question.id},
      );
    }
    state = AsyncData(next);
  }

  Future<TestResult?> submit() async {
    final session = state.value;
    if (session == null) return null;
    await ref.read(audioPlayerControllerProvider.notifier).stop();
    final result = await ref
        .read(testRepositoryProvider)
        .submitSession(
          sessionId: session.sessionId,
          exam: session.exam,
          answers: session.answers,
          startedAtUtc: session.startedAtUtc,
        );
    state = const AsyncData(null);
    ref.invalidate(testResultsProvider);
    return result;
  }

  Future<void> _loadAudio(Question question) async {
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    await controller.loadQuestion(question);
    await controller.togglePlayPause();
  }
}

final testSessionControllerProvider =
    AsyncNotifierProvider<TestSessionController, TestSessionState?>(
      TestSessionController.new,
    );
