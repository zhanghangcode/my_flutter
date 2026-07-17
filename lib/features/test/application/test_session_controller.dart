import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../player/application/audio_player_controller.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/test_models.dart';

/// 実施中テストの問題位置、回答、再生済み問題を保持する immutable State。
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

  /// 現在のインデックスに対応する問題を返します。
  Question get currentQuestion => exam.questions[currentIndex];

  /// 変更対象だけを置き換えた新しいセッション State を返します。
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

/// テスト開始から提出までの状態遷移と一度きりの音声再生を管理する AsyncNotifier。
///
/// UI は AsyncValue を購読することで読み込み・エラー・セッション状態を描画し、
/// 回答や問題移動はこの Controller を通して更新します。
class TestSessionController extends AsyncNotifier<TestSessionState?> {
  @override
  Future<TestSessionState?> build() async => null;

  /// 試験データと永続セッションを作成し、最初の問題の音声を再生します。
  Future<void> start(String examId) async {
    state = const AsyncLoading();
    // AsyncValue.guard で例外を AsyncError に変換し、画面のエラー表示へ流します。
    state = await AsyncValue.guard(() async {
      final repository = ref.read(practiceRepositoryProvider);
      final summary = (await repository.getExams())
          .where((item) => item.id == examId)
          .firstOrNull;
      if (summary == null) throw StateError('試験データが見つかりません。');
      if (!summary.supportsTest) {
        throw StateError('この教材は練習専用です。');
      }
      final exam = await repository.getExam(examId);
      if (exam.questions.isEmpty) throw StateError('問題がありません。');
      if (exam.questions.any((question) => !question.isGradable)) {
        throw StateError('採点データが未収録の問題があります。');
      }
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

  /// 現在問題の選択回答を immutable Map として更新します。
  void select(String optionId) {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(
      session.copyWith(
        answers: {...session.answers, session.currentQuestion.id: optionId},
      ),
    );
  }

  /// 指定インデックスへ移動し、未再生の問題だけ音声を開始します。
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
      // playedQuestionIds により、一度聞いた問題へ戻っても再再生しません。
      await _loadAudio(question);
      next = next.copyWith(
        playedQuestionIds: {...next.playedQuestionIds, question.id},
      );
    }
    state = AsyncData(next);
  }

  /// 現在の回答を採点・保存し、結果画面へ渡すモデルを返します。
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
    // 一覧の結果 Stream を再評価し、提出直後の履歴を反映します。
    ref.invalidate(testResultsProvider);
    return result;
  }

  Future<void> _loadAudio(Question question) async {
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    await controller.loadQuestion(question);
    await controller.togglePlayPause();
  }
}

/// テストセッションの非同期 State と操作 API を画面へ公開する Provider。
final testSessionControllerProvider =
    AsyncNotifierProvider<TestSessionController, TestSessionState?>(
      TestSessionController.new,
    );
