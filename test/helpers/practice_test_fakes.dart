import 'dart:async';

import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/player/domain/audio_resource_resolver.dart';
import 'package:nihongo_listening/features/player/domain/audio_source_location.dart';
import 'package:nihongo_listening/features/practice/domain/learning_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/domain/practice_repository.dart';

/// PlayerとControllerのテストで利用する、Pluginに依存しない音声サービス。
class FakeAudioPlaybackService implements AudioPlaybackService {
  /// 再生位置をテストから任意に通知する StreamController。
  final positionController = StreamController<Duration>.broadcast();

  /// バッファ済み位置をテストから任意に通知する StreamController。
  final bufferedPositionController = StreamController<Duration>.broadcast();

  /// 読み込んだ音源の長さを通知する StreamController。
  final durationController = StreamController<Duration?>.broadcast();

  /// Plugin の処理状態を模擬するための StreamController。
  final stateController = StreamController<AudioEngineSnapshot>.broadcast();

  /// Asset path ごとに返す再生時間。未指定時は 30 秒を使用します。
  final Map<String, Duration> durations = {};

  /// 指定 Asset の load 完了をテストから遅延させるための Completer 一覧。
  final Map<String, Completer<Duration>> pendingLoads = {};

  /// 指定 Asset の load で送出するエラー一覧。
  final Map<String, Object> loadErrors = {};

  /// loadSourceに渡された音源場所の履歴。
  final List<AudioSourceLocation> loadedSources = [];

  /// 既存テストがpathだけを検証するための互換用一覧。
  List<String> get loadedAssets => [
    for (final source in loadedSources) source.path,
  ];

  /// stop と load の実行順を検証するための操作履歴。
  final List<String> operationLog = [];

  /// stop の完了をテストから遅延させるための任意の Completer。
  Completer<void>? pendingStop;

  /// 最後に seek された位置。
  Duration lastSeekPosition = Duration.zero;

  /// seek の呼び出し回数。
  int seekCount = 0;

  /// 最後に設定された再生速度。
  double lastSpeed = 1;

  /// play の呼び出し回数。
  int playCount = 0;

  /// pause の呼び出し回数。
  int pauseCount = 0;

  /// stop の呼び出し回数。
  int stopCount = 0;

  /// seek 時に一時停止状態を通知するかどうか。
  bool pauseOnSeek = false;

  /// [playing] getter が返す現在の再生フラグ。
  bool _playing = false;

  /// 問題全体のループ設定を検証するための保持値。
  bool questionLooping = false;

  /// テスト用サービスが再生中かどうかを返します。
  @override
  bool get playing => _playing;

  /// 再生位置の通知 Stream を公開します。
  @override
  Stream<Duration> get positionStream => positionController.stream;

  /// バッファ済み位置の通知 Stream を公開します。
  @override
  Stream<Duration> get bufferedPositionStream =>
      bufferedPositionController.stream;

  /// 音源の長さの通知 Stream を公開します。
  @override
  Stream<Duration?> get durationStream => durationController.stream;

  /// エンジン状態の通知 Stream を公開します。
  @override
  Stream<AudioEngineSnapshot> get stateStream => stateController.stream;

  /// Asset/Fileを読み込み、テスト設定に応じて再生時間またはエラーを返します。
  @override
  Future<Duration> loadSource(AudioSourceLocation source) async {
    final path = source.path;
    operationLog.add('load:$path');
    loadedSources.add(source);
    final error = loadErrors[path];
    if (error != null) throw error;
    final pending = pendingLoads[path];
    final duration = pending == null
        ? durations[path] ?? const Duration(seconds: 30)
        : await pending.future;
    durationController.add(duration);
    return duration;
  }

  /// 再生状態へ遷移したことを記録し、ready 状態を通知します。
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

  /// 一時停止状態へ遷移したことを記録し、ready 状態を通知します。
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

  /// 停止の順序を記録し、必要に応じてテスト側の完了を待機します。
  @override
  Future<void> stop() async {
    stopCount++;
    operationLog.add('stop:start');
    _playing = false;
    final pending = pendingStop;
    if (pending != null) await pending.future;
    stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.idle,
      ),
    );
    operationLog.add('stop:complete');
  }

  /// 最後に seek された位置を記録し、位置 Stream へ通知します。
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

  /// 最後に指定された再生速度を保持します。
  @override
  Future<void> setSpeed(double speed) async => lastSpeed = speed;

  /// 問題全体のループ設定を保持します。
  @override
  Future<void> setQuestionLooping(bool enabled) async {
    questionLooping = enabled;
  }

  /// テストで開いたすべての StreamController を閉じます。
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

/// すべての問題をBundle Assetとして解決するControllerテスト用Resolver。
class FakeAudioResourceResolver implements AudioResourceResolver {
  /// questionIdごとにLocal Fileへ置き換える任意のpathを受け取ります。
  const FakeAudioResourceResolver({
    this.localPaths = const {},
    this.errorMessage,
  });

  /// questionIdをキーとするLocal File pathです。
  final Map<String, String> localPaths;

  /// 全問題の解決時に送出する任意の利用者向けエラーです。
  final String? errorMessage;

  @override
  Future<AudioSourceLocation> resolve(Question question) async {
    final message = errorMessage;
    if (message != null) throw AudioResourceUnavailableException(message);
    final localPath = localPaths[question.id];
    return localPath == null
        ? AudioSourceLocation.asset(question.audioAssetPath)
        : AudioSourceLocation.file(localPath);
  }
}

/// 順序付きの試験データをそのまま返すテスト用Repository。
class FakePracticeRepository implements PracticeRepository {
  /// [exam] を固定で返すテスト用 Repository を構築します。
  FakePracticeRepository(
    this.exam, {
    this.supportsTest = true,
    this.audioDeliveryMode = AudioDeliveryMode.bundled,
    this.audioResourceVersion = 1,
  });

  /// テスト対象として返す試験データ。
  final ExamResource exam;

  /// 試験がテストモードに対応するかどうか。
  final bool supportsTest;

  /// テスト教材の音声配送方式です。
  final AudioDeliveryMode audioDeliveryMode;

  /// テスト教材の音声リソースversionです。
  final int audioResourceVersion;

  /// 固定試験からカタログ用の要約を生成します。
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
      audioDeliveryMode: audioDeliveryMode,
      audioResourceVersion: audioResourceVersion,
    ),
  ];

  /// [examId] が一致する場合だけ固定試験を返します。
  @override
  Future<ExamResource> getExam(String examId) async {
    if (examId != exam.id) throw StateError('試験が見つかりません。');
    return exam;
  }

  /// 固定試験内から [questionId] が一致する問題を返します。
  @override
  Future<Question> getQuestion(String questionId) async =>
      exam.questions.firstWhere((question) => question.id == questionId);

  /// [questionId] を基準に [offset] だけ移動した問題を返します。
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
  /// 問題 ID ごとの保存済み学習進捗。
  final Map<String, LearningProgress> progress = {};

  /// 問題 ID ごとの保存済み回答。
  final Map<String, AnswerRecord> answers = {};

  /// 問題を開いた順序を確認するための履歴。
  final List<String> openedQuestions = [];

  /// お気に入り問題を持たない固定 Stream を返します。
  @override
  Stream<Set<String>> watchFavoriteQuestionIds() => Stream.value({});

  /// お気に入り文を持たない固定 Stream を返します。
  @override
  Stream<Set<String>> watchFavoriteSentenceIds() => Stream.value({});

  /// 誤答問題を持たない固定 Stream を返します。
  @override
  Stream<List<String>> watchWrongQuestionIds() => Stream.value([]);

  /// 最近の問題を持たない固定 Stream を返します。
  @override
  Stream<List<String>> watchRecentQuestionIds() => Stream.value([]);

  /// お気に入り状態は保存せず、インターフェースだけを満たします。
  @override
  Future<void> toggleQuestionFavorite(String questionId) async {}

  /// 文のお気に入り状態は保存せず、インターフェースだけを満たします。
  @override
  Future<void> toggleSentenceFavorite(
    String sentenceId,
    String questionId,
  ) async {}

  /// [questionId] の保存済み回答を返します。
  @override
  Future<AnswerRecord?> getAnswer(String questionId) async =>
      answers[questionId];

  /// [questionId] の回答を保存し、再回答時は試行回数を増やします。
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

  /// [questionId] の保存済み進捗を返します。
  @override
  Future<LearningProgress?> getProgress(String questionId) async =>
      progress[questionId];

  /// 開いた [questionId] を履歴へ追加します。
  @override
  Future<void> markQuestionOpened(String questionId) async {
    openedQuestions.add(questionId);
  }

  /// 再生位置と表示モードを、問題ごとのメモリ上の進捗へ保存します。
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

  /// テストで保持した回答・進捗・履歴をすべて初期化します。
  @override
  Future<void> clearAll() async {
    progress.clear();
    answers.clear();
    openedQuestions.clear();
  }
}

/// 問題切り替えテスト向けに、指定数の問題を持つ試験を生成します。
///
/// [questionCount] は順序・境界・音声パスの検証に必要な最小構成の問題数です。
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
