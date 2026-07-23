import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../player/application/audio_player_controller.dart';
import '../../player/domain/question_playback_mode.dart';
import '../domain/learning_repository.dart';
import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// 問題切り替え後のRouteへ引き継ぐ一時的な情報。
class PracticeQuestionChange {
  /// 問題切り替え後のRouteへ渡す一時情報を生成します。
  ///
  /// [question]は即時描画する目標問題、[previousQuestionId]と[previousPositionMs]は旧問題の
  /// 進捗保存用です。[resumePlayback]は音源準備後の自動再生可否、[speed]と[playbackMode]は
  /// 引き継ぐPlayer設定です。生成時にRouteや音声を直接変更しません。
  const PracticeQuestionChange({
    required this.question,
    required this.previousQuestionId,
    required this.previousPositionMs,
    required this.mode,
    required this.resumePlayback,
    required this.speed,
    required this.playbackMode,
  });

  /// 新しいRouteで即時表示する目標問題です。
  final Question question;

  /// 切り替え前の問題IDです。進捗保存に使用します。
  final String previousQuestionId;

  /// 切り替え前の再生位置。問題音声先頭からのmillisecondsです。
  final int previousPositionMs;

  /// 目標問題へ引き継ぐContentModeです。
  final ContentMode mode;

  /// 旧問題が再生中だった場合に`true`となる自動再生要求です。
  final bool resumePlayback;

  /// 目標音源へ引き継ぐ再生倍率です。
  final double speed;

  /// 目標問題へ引き継ぐ問題単位の再生modeです。
  final QuestionPlaybackMode playbackMode;

  /// 目標問題が属する試験IDを返します。
  String get examId => question.examId;

  /// 目標問題の一意なIDを返します。
  String get questionId => question.id;
}

/// 練習詳細画面で保持する表示モード、選択回答、提出状態。
///
/// 音声の状態は AudioPlayerController が別に管理し、この State は
/// 問題演習に固有の状態だけを担当します。
class PracticeDetailState {
  /// 練習詳細の表示・回答・切り替えStateを生成します。
  ///
  /// すべて任意で、未指定時はTranscript表示・問題未選択・未読み込みの初期値を使用します。
  /// nullableなID・回答・エラーが`null`の場合は未選択、未保存、またはエラーなしを表します。
  const PracticeDetailState({
    this.questionId,
    this.mode = ContentMode.transcript,
    this.selectedOptionId,
    this.submitted = false,
    this.savedAnswer,
    this.loading = false,
    this.currentQuestionIndex = -1,
    this.questionCount = 0,
    this.isChangingQuestion = false,
    this.errorMessage,
  });

  /// 現在表示する問題IDです。`null`は問題未選択を表します。
  final String? questionId;

  /// 現在選択されている詳細表示モードです。
  final ContentMode mode;

  /// 未提出の選択肢IDです。未選択時は`null`です。
  final String? selectedOptionId;

  /// 現在の選択を提出済みとして表示するかを示します。
  final bool submitted;

  /// Repositoryから復元した最後の回答です。未保存時は`null`です。
  final AnswerRecord? savedAnswer;

  /// 問題・回答の読み込み中かを示します。
  final bool loading;

  /// 試験内における現在問題の0始まりindexです。未確定時は`-1`です。
  final int currentQuestionIndex;

  /// 試験に含まれる問題数です。未読み込み時は`0`です。
  final int questionCount;

  /// Route置換と音源切り替えが進行中かを示します。
  final bool isChangingQuestion;

  /// 学習状態の読み込み失敗内容です。失敗していない時は`null`です。
  final String? errorMessage;

  /// 現在のindexが有効で、前に問題が存在する場合だけtrueを返します。
  bool get hasPreviousQuestion =>
      currentQuestionIndex > 0 && currentQuestionIndex < questionCount;

  /// 現在のindexが有効で、後ろに問題が存在する場合だけtrueを返します。
  bool get hasNextQuestion =>
      currentQuestionIndex >= 0 &&
      currentQuestionIndex < questionCount - 1 &&
      questionCount > 0;

  /// 変更対象だけを置き換えた新しいimmutable Stateを返します。
  ///
  /// clearフラグが`true`の場合は対応するnullable値を`null`へ更新します。元のStateは変更しません。
  PracticeDetailState copyWith({
    String? questionId,
    ContentMode? mode,
    String? selectedOptionId,
    bool clearSelection = false,
    bool? submitted,
    AnswerRecord? savedAnswer,
    bool? loading,
    int? currentQuestionIndex,
    int? questionCount,
    bool? isChangingQuestion,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PracticeDetailState(
      questionId: questionId ?? this.questionId,
      mode: mode ?? this.mode,
      selectedOptionId: clearSelection
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      submitted: submitted ?? this.submitted,
      savedAnswer: savedAnswer ?? this.savedAnswer,
      loading: loading ?? this.loading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questionCount: questionCount ?? this.questionCount,
      isChangingQuestion: isChangingQuestion ?? this.isChangingQuestion,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// 練習詳細の回答操作と学習記録の読み込みを管理する Notifier。
///
/// Widget は ref.watch で [PracticeDetailState] を購読し、操作時のみ ref.read で
/// この Controller を呼び出します。永続化は Repository に委譲します。
class PracticeDetailController extends Notifier<PracticeDetailState> {
  /// 進捗・回答・お気に入りを永続化するRepositoryです。[build]で取得します。
  late LearningRepository _learningRepository;

  /// 教材JSONから問題・試験を読み込むRepositoryです。[build]で取得します。
  late PracticeRepository _practiceRepository;

  /// 現在試験の表示順を保った問題一覧です。未読込時は空です。
  List<Question> _questions = const [];

  @override
  /// Repository依存をProviderから取得し、空の詳細Stateを返します。
  PracticeDetailState build() {
    // Provider 経由で Repository を受け取り、Controller と Drift を直接結合しません。
    _learningRepository = ref.watch(learningRepositoryProvider);
    _practiceRepository = ref.watch(practiceRepositoryProvider);
    return const PracticeDetailState();
  }

  /// 指定問題の保存済み表示モードと回答を読み込み、閲覧回数を更新します。
  ///
  /// [questionId]は読み込む問題、[preferredMode]が非`null`なら保存済みモードより優先します。
  /// Repository失敗時はerrorMessageをStateへ設定し、例外をUIへ再送出しません。
  Future<void> open(String questionId, {ContentMode? preferredMode}) async {
    // 同じ問題に対する Widget の再 build で、閲覧回数を重複加算しないようにします。
    if (state.questionId == questionId && !state.loading) return;
    final continuingChange =
        state.questionId == questionId && state.isChangingQuestion;
    state = PracticeDetailState(
      questionId: questionId,
      mode: _visibleMode(preferredMode ?? state.mode),
      loading: true,
      currentQuestionIndex: continuingChange ? state.currentQuestionIndex : -1,
      questionCount: continuingChange ? state.questionCount : 0,
      isChangingQuestion: continuingChange,
    );
    try {
      final question = await _practiceRepository.getQuestion(questionId);
      final exam = await _practiceRepository.getExam(question.examId);
      final index = exam.questions.indexWhere((item) => item.id == questionId);
      if (index < 0) {
        throw StateError('問題一覧に対象の問題がありません。');
      }
      _questions = exam.questions;
      final progress = await _learningRepository.getProgress(questionId);
      final answer = await _learningRepository.getAnswer(questionId);
      await _learningRepository.markQuestionOpened(questionId);
      state = PracticeDetailState(
        questionId: questionId,
        mode: _visibleMode(
          preferredMode ?? progress?.lastContentMode ?? ContentMode.transcript,
        ),
        savedAnswer: answer,
        currentQuestionIndex: index,
        questionCount: exam.questions.length,
        isChangingQuestion: continuingChange,
      );
    } catch (error) {
      state = PracticeDetailState(
        questionId: questionId,
        mode: _visibleMode(preferredMode ?? state.mode),
        currentQuestionIndex: continuingChange
            ? state.currentQuestionIndex
            : -1,
        questionCount: continuingChange ? state.questionCount : 0,
        isChangingQuestion: continuingChange,
        errorMessage: '学習記録を読み込めませんでした。\n$error',
      );
    }
  }

  /// 詳細画面の表示モードを切り替えます。
  ///
  /// [mode]は次回rebuildで表示するContentModeです。
  void setMode(ContentMode mode) => state = state.copyWith(mode: mode);

  /// タブを非表示にした`explanation`を、UIから選択可能な既定モードへ読み替えます。
  ///
  /// Driftに保存済みの`lastContentMode`が`explanation`のまま復元されても、
  /// タブの無い状態を防ぎます。
  ContentMode _visibleMode(ContentMode mode) =>
      mode == ContentMode.explanation ? ContentMode.transcript : mode;

  /// 未提出時だけ選択中の回答を更新します。
  ///
  /// [optionId]は選択した選択肢IDです。提出済みなら既存結果を保護して何もしません。
  void selectOption(String optionId) {
    if (state.submitted) return;
    state = state.copyWith(selectedOptionId: optionId);
  }

  /// 選択回答を採点して保存し、UIを結果表示へ切り替えます。
  ///
  /// [question]が採点可能で、未提出の選択肢がある場合だけRepositoryへ保存します。
  Future<void> submit(Question question) async {
    if (!question.isGradable) return;
    final selected = state.selectedOptionId;
    if (selected == null || state.submitted) return;
    final isCorrect = selected == question.correctOptionId;
    await _learningRepository.saveAnswer(question.id, selected, isCorrect);
    final record = await _learningRepository.getAnswer(question.id);
    state = state.copyWith(submitted: true, savedAnswer: record);
  }

  /// 保存済み履歴は維持したまま、画面上の選択と提出状態を初期化します。
  void retry() {
    state = state.copyWith(clearSelection: true, submitted: false);
  }

  /// 現在問題から相対位置にある問題へ切り替える準備を行います。
  ///
  /// [offset]は正なら次、負なら前への移動数、[speed]は目標音源へ引き継ぐ倍率です。
  /// 範囲外または切り替え中は`null`を返します。
  Future<PracticeQuestionChange?> changeQuestion(
    int offset, {
    required double speed,
  }) async {
    final targetIndex = state.currentQuestionIndex + offset;
    return _changeToIndex(targetIndex, speed: speed);
  }

  /// 問題Pickerで選択した問題へ、前後ボタンと同じ手順で切り替えます。
  ///
  /// [questionId]は目標問題ID、[speed]は目標音源へ引き継ぐ倍率です。不明なIDや切り替え中は
  /// `null`を返します。
  Future<PracticeQuestionChange?> changeToQuestion(
    String questionId, {
    required double speed,
  }) async {
    final targetIndex = _questions.indexWhere(
      (question) => question.id == questionId,
    );
    return _changeToIndex(targetIndex, speed: speed);
  }

  /// 音声完了後に次問題へ進み、全題ループ時だけ末尾から先頭へ戻します。
  ///
  /// [wrap]が`true`なら末尾から先頭へ戻り、[speed]は次音源へ引き継ぎます。進めない場合は
  /// `null`を返します。
  Future<PracticeQuestionChange?> advanceAfterCompletion({
    required bool wrap,
    required double speed,
  }) {
    if (_questions.isEmpty || state.currentQuestionIndex < 0) {
      return Future<PracticeQuestionChange?>.value();
    }
    var targetIndex = state.currentQuestionIndex + 1;
    if (targetIndex >= _questions.length) {
      if (!wrap) return Future<PracticeQuestionChange?>.value();
      targetIndex = 0;
    }
    return _changeToIndex(
      targetIndex,
      speed: speed,
      resumePlaybackOverride: true,
    );
  }

  /// Route置換後に、切り替え元問題の位置と表示モードを保存します。
  ///
  /// [change]に含まれる旧問題ID・milliseconds位置・ContentModeをRepositoryへ渡します。
  Future<void> savePreviousProgress(PracticeQuestionChange change) {
    return _learningRepository.saveProgress(
      change.previousQuestionId,
      positionMs: change.previousPositionMs,
      contentMode: change.mode,
    );
  }

  /// 新しい画面の学習状態と音声準備が完了した時点で操作ロックを解除します。
  ///
  /// [questionId]が現在Stateの問題IDと一致する場合だけ解除し、古いRouteの完了通知を無視します。
  void completeQuestionChange(String questionId) {
    if (state.questionId != questionId) return;
    state = state.copyWith(isChangingQuestion: false, loading: false);
  }

  /// 指定indexへの切り替え情報を生成し、旧音源の停止を開始します。
  ///
  /// [targetIndex]は現在試験内の0始まりindex、[speed]は引き継ぐ倍率です。
  /// [resumePlaybackOverride]が非`null`なら自動再生可否を明示します。境界外・読み込み中・
  /// 切り替え中は`null`を返します。
  Future<PracticeQuestionChange?> _changeToIndex(
    int targetIndex, {
    required double speed,
    bool? resumePlaybackOverride,
  }) {
    if (state.isChangingQuestion ||
        state.loading ||
        state.questionId == null ||
        _questions.isEmpty ||
        targetIndex < 0 ||
        targetIndex >= _questions.length ||
        targetIndex == state.currentQuestionIndex) {
      return Future<PracticeQuestionChange?>.value();
    }

    final currentPlayer = ref.read(audioPlayerControllerProvider);
    final resumePlayback = resumePlaybackOverride ?? currentPlayer.isPlaying;
    final playbackMode = currentPlayer.playbackMode;
    final currentQuestionId = state.questionId!;
    final mode = state.mode;
    final targetQuestion = _questions[targetIndex];
    // 目標問題の本文を先に描画できるよう、音源loadと進捗保存は新Routeへ移します。
    state = PracticeDetailState(
      questionId: targetQuestion.id,
      mode: mode,
      loading: true,
      currentQuestionIndex: targetIndex,
      questionCount: _questions.length,
      isChangingQuestion: true,
    );
    final audioController = ref.read(audioPlayerControllerProvider.notifier);
    unawaited(audioController.beginQuestionChange());

    return Future<PracticeQuestionChange?>.value(
      PracticeQuestionChange(
        question: targetQuestion,
        previousQuestionId: currentQuestionId,
        previousPositionMs: currentPlayer.position.inMilliseconds,
        mode: mode,
        resumePlayback: resumePlayback,
        speed: speed,
        playbackMode: playbackMode,
      ),
    );
  }
}

/// 練習詳細の State と操作 API を画面へ公開する Provider。
final practiceDetailControllerProvider =
    NotifierProvider<PracticeDetailController, PracticeDetailState>(
      PracticeDetailController.new,
    );
