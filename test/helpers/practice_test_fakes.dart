import 'dart:async';

import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/practice/domain/learning_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/domain/practice_repository.dart';

/// PlayerとControllerのテストで利用する、Pluginに依存しない音声サービス。
class FakeAudioPlaybackService implements AudioPlaybackService {
  final positionController = StreamController<Duration>.broadcast();
  final bufferedPositionController = StreamController<Duration>.broadcast();
  final durationController = StreamController<Duration?>.broadcast();
  final stateController = StreamController<AudioEngineSnapshot>.broadcast();

  final Map<String, Duration> durations = {};
  final Map<String, Completer<Duration>> pendingLoads = {};
  final Map<String, Object> loadErrors = {};
  final List<String> loadedAssets = [];
  Duration lastSeekPosition = Duration.zero;
  int seekCount = 0;
  double lastSpeed = 1;
  int playCount = 0;
  int pauseCount = 0;
  int stopCount = 0;
  bool pauseOnSeek = false;
  bool _playing = false;
  bool questionLooping = false;

  @override
  bool get playing => _playing;

  @override
  Stream<Duration> get positionStream => positionController.stream;

  @override
  Stream<Duration> get bufferedPositionStream =>
      bufferedPositionController.stream;

  @override
  Stream<Duration?> get durationStream => durationController.stream;

  @override
  Stream<AudioEngineSnapshot> get stateStream => stateController.stream;

  @override
  Future<Duration> loadAsset(String assetPath) async {
    loadedAssets.add(assetPath);
    final error = loadErrors[assetPath];
    if (error != null) throw error;
    final pending = pendingLoads[assetPath];
    final duration = pending == null
        ? durations[assetPath] ?? const Duration(seconds: 30)
        : await pending.future;
    durationController.add(duration);
    return duration;
  }

  @override
  Future<void> play() async {
    playCount++;
    _playing = true;
    stateController.add(
      const AudioEngineSnapshot(
        playing: true,
        processing: AudioEngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> pause() async {
    pauseCount++;
    _playing = false;
    stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.ready,
      ),
    );
  }

  @override
  Future<void> stop() async {
    stopCount++;
    _playing = false;
    stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.idle,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async {
    seekCount++;
    lastSeekPosition = position;
    positionController.add(position);
    if (pauseOnSeek) {
      _playing = false;
      stateController.add(
        const AudioEngineSnapshot(
          playing: false,
          processing: AudioEngineProcessing.ready,
        ),
      );
    }
  }

  @override
  Future<void> setSpeed(double speed) async => lastSpeed = speed;

  @override
  Future<void> setQuestionLooping(bool enabled) async {
    questionLooping = enabled;
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      positionController.close(),
      bufferedPositionController.close(),
      durationController.close(),
      stateController.close(),
    ]);
  }
}

/// 順序付きの試験データをそのまま返すテスト用Repository。
class FakePracticeRepository implements PracticeRepository {
  FakePracticeRepository(this.exam, {this.supportsTest = true});

  final ExamResource exam;
  final bool supportsTest;

  @override
  Future<List<ExamSummary>> getExams() async => [
    ExamSummary(
      id: exam.id,
      year: 2026,
      month: 7,
      titleJa: exam.titleJa,
      audioQuality: 'demo',
      questionCount: exam.questions.length,
      resourcePath: 'unused.json',
      supportsTest: supportsTest,
    ),
  ];

  @override
  Future<ExamResource> getExam(String examId) async {
    if (examId != exam.id) throw StateError('試験が見つかりません。');
    return exam;
  }

  @override
  Future<Question> getQuestion(String questionId) async =>
      exam.questions.firstWhere((question) => question.id == questionId);

  @override
  Future<Question?> getAdjacentQuestion(String questionId, int offset) async {
    final index = exam.questions.indexWhere(
      (question) => question.id == questionId,
    );
    final targetIndex = index + offset;
    if (index < 0 || targetIndex < 0 || targetIndex >= exam.questions.length) {
      return null;
    }
    return exam.questions[targetIndex];
  }
}

/// 永続化の呼び出し結果をメモリ上で確認するテスト用Repository。
class FakeLearningRepository implements LearningRepository {
  final Map<String, LearningProgress> progress = {};
  final Map<String, AnswerRecord> answers = {};
  final List<String> openedQuestions = [];

  @override
  Stream<Set<String>> watchFavoriteQuestionIds() => Stream.value({});

  @override
  Stream<Set<String>> watchFavoriteSentenceIds() => Stream.value({});

  @override
  Stream<List<String>> watchWrongQuestionIds() => Stream.value([]);

  @override
  Stream<List<String>> watchRecentQuestionIds() => Stream.value([]);

  @override
  Future<void> toggleQuestionFavorite(String questionId) async {}

  @override
  Future<void> toggleSentenceFavorite(
    String sentenceId,
    String questionId,
  ) async {}

  @override
  Future<AnswerRecord?> getAnswer(String questionId) async =>
      answers[questionId];

  @override
  Future<void> saveAnswer(
    String questionId,
    String optionId,
    bool isCorrect,
  ) async {
    final previous = answers[questionId];
    answers[questionId] = AnswerRecord(
      questionId: questionId,
      selectedOptionId: optionId,
      isCorrect: isCorrect,
      attemptCount: (previous?.attemptCount ?? 0) + 1,
    );
  }

  @override
  Future<LearningProgress?> getProgress(String questionId) async =>
      progress[questionId];

  @override
  Future<void> markQuestionOpened(String questionId) async {
    openedQuestions.add(questionId);
  }

  @override
  Future<void> saveProgress(
    String questionId, {
    required int positionMs,
    required ContentMode contentMode,
  }) async {
    final previous = progress[questionId];
    progress[questionId] = LearningProgress(
      questionId: questionId,
      lastPositionMs: positionMs,
      lastContentMode: contentMode,
      practiceCount: previous?.practiceCount ?? 1,
      lastPracticedAtUtc: DateTime.utc(2026, 7, 17),
    );
  }

  @override
  Future<void> clearAll() async {
    progress.clear();
    answers.clear();
    openedQuestions.clear();
  }
}

/// 問題切り替えテスト向けに、指定数の問題を持つ試験を生成します。
ExamResource buildTestExam({int questionCount = 3}) => ExamResource(
  schemaVersion: 2,
  id: 'exam-1',
  titleJa: 'テスト試験',
  questions: [
    for (var index = 0; index < questionCount; index++)
      Question(
        id: 'q${index + 1}',
        examId: 'exam-1',
        section: 1,
        number: index + 1,
        type: '会話',
        promptJa: '問題${index + 1}',
        options: const [AnswerOption(id: 'a', label: 1, textJa: '選択肢')],
        correctOptionId: 'a',
        audioAssetPath: 'audio/q${index + 1}.mp3',
        sentences: [
          TranscriptSentence(
            id: 'q${index + 1}-s1',
            order: 0,
            textJa: '本文',
            startMs: 0,
            endMs: 1000,
          ),
        ],
        explanation: const QuestionExplanation(ja: '解説', zh: '说明'),
      ),
  ],
);
