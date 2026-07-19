import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../player/application/audio_player_controller.dart';
import '../../practice/domain/practice_models.dart';
import '../domain/test_models.dart';

/// 実施中テストの問題位置、回答、再生済み問題を保持する immutable State。
class TestSessionState {
  /// 実施中テストのimmutable Stateを生成します。
  ///
  /// [sessionId]は永続化ID、[exam]は対象試験、[startedAtUtc]はUTC開始日時です。
  /// [currentIndex]は0始まり、[answers]の未回答はキーなし、[playedQuestionIds]は再生済みID集合です。
  const TestSessionState({
    required this.sessionId,
    required this.exam,
    required this.startedAtUtc,
    this.currentIndex = 0,
    this.answers = const {},
    this.playedQuestionIds = const {},
  });

  /// Driftへ保存したテストセッションIDです。
  final int sessionId;

  /// 問題と正解を持つ対象試験です。
  final ExamResource exam;

  /// テストを開始したUTC日時です。
  final DateTime startedAtUtc;

  /// 現在表示する問題の0始まりindexです。
  final int currentIndex;

  /// 問題IDをキーとする選択肢IDのMapです。未回答はキーなしまたは`null`です。
  final Map<String, String?> answers;

  /// 音声を一度再生した問題IDの集合です。
  final Set<String> playedQuestionIds;

  /// 現在のインデックスに対応する問題を返します。
  Question get currentQuestion => exam.questions[currentIndex];

  /// 変更対象だけを置き換えた新しいセッションStateを返します。
  ///
  /// 任意引数が`null`の場合は現在値を維持し、元のStateは変更しません。
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
  /// 初期状態としてテスト未開始を表す`null`を非同期で返します。
  Future<TestSessionState?> build() async => null;

  /// 試験データと永続セッションを作成し、最初の問題の音声を再生します。
  ///
  /// [examId]が採点可能な教材を指す場合だけ開始します。例外はAsyncValue.guardにより
  /// AsyncErrorへ変換され、開始中はAsyncLoadingをUIへ公開します。
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

  /// 現在問題の選択回答をimmutable Mapとして更新します。
  ///
  /// [optionId]は選択した選択肢IDです。セッション未開始時は何もしません。
  void select(String optionId) {
    final session = state.value;
    if (session == null) return;
    state = AsyncData(
      session.copyWith(
        answers: {...session.answers, session.currentQuestion.id: optionId},
      ),
    );
  }

  /// 指定indexへ移動し、未再生の問題だけ音声を開始します。
  ///
  /// [index]が範囲外またはセッション未開始なら何もしません。移動前に旧音声を停止し、
  /// 初めて開く問題だけ先頭から再生します。
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
  ///
  /// セッション未開始時は`null`を返します。提出後はStateを`null`へ戻し、結果一覧Providerを
  /// invalidateします。
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

  /// [question]の音源を読み込み、Test用に一度だけ再生します。
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
