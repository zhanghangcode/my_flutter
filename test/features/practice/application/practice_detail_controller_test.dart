import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/player/domain/question_playback_mode.dart';
import 'package:nihongo_listening/features/practice/application/practice_detail_controller.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

import '../../../helpers/practice_test_fakes.dart';

void main() {
  test('問題数とindexから前後問題の有無を安全に判定する', () {
    // Given / When / Then: 先頭、中央、末尾、1問、不正indexの境界を確認します。
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 0,
        questionCount: 3,
      ).hasPreviousQuestion,
      isFalse,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 1,
        questionCount: 3,
      ).hasPreviousQuestion,
      isTrue,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 1,
        questionCount: 3,
      ).hasNextQuestion,
      isTrue,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 2,
        questionCount: 3,
      ).hasNextQuestion,
      isFalse,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 0,
        questionCount: 1,
      ).hasPreviousQuestion,
      isFalse,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: 0,
        questionCount: 1,
      ).hasNextQuestion,
      isFalse,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: -1,
        questionCount: 3,
      ).hasPreviousQuestion,
      isFalse,
    );
    expect(
      const PracticeDetailState(
        currentQuestionIndex: -1,
        questionCount: 3,
      ).hasNextQuestion,
      isFalse,
    );
  });

  group('PracticeDetailControllerの問題切り替え', () {
    late ExamResource exam;
    late FakeAudioPlaybackService audio;
    late FakeLearningRepository learning;
    late ProviderContainer container;

    setUp(() {
      exam = buildTestExam();
      audio = FakeAudioPlaybackService();
      learning = FakeLearningRepository();
      container = ProviderContainer(
        overrides: [
          practiceRepositoryProvider.overrideWithValue(
            FakePracticeRepository(exam),
          ),
          learningRepositoryProvider.overrideWithValue(learning),
          audioPlaybackServiceProvider.overrideWithValue(audio),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await audio.dispose();
    });

    test('次問題の表示情報を即時返し、音源loadと進捗保存をRoute置換後へ委譲する', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q1');
      detail.setMode(ContentMode.combined);
      detail.selectOption('a');
      await detail.submit(exam.questions.first);
      await player.loadQuestion(exam.questions.first, speed: 1.25);
      await player.cycleQuestionPlaybackMode();
      await player.togglePlayPause();
      await player.seek(const Duration(seconds: 3));
      await Future<void>.delayed(Duration.zero);

      // When: 再生中の1問目から次の問題へ切り替えます。
      final change = await detail.changeQuestion(1, speed: 1.25);

      // Then: 音源loadを待たず、目標本文と再生条件をRoute入力として返します。
      expect(change?.questionId, 'q2');
      expect(change?.question, exam.questions[1]);
      expect(change?.previousQuestionId, 'q1');
      expect(change?.previousPositionMs, 3000);
      expect(change?.mode, ContentMode.combined);
      expect(change?.resumePlayback, isTrue);
      expect(change?.speed, 1.25);
      expect(change?.playbackMode, QuestionPlaybackMode.repeatAll);
      expect(audio.loadedAssets, ['audio/q1.mp3']);
      expect(learning.progress['q1'], isNull);
      expect(
        container.read(audioPlayerControllerProvider).position,
        Duration.zero,
      );
      expect(
        container.read(audioPlayerControllerProvider).playbackMode,
        QuestionPlaybackMode.repeatAll,
      );
      expect(
        container.read(audioPlayerControllerProvider).activeSentenceId,
        isNull,
      );
      expect(container.read(practiceDetailControllerProvider).questionId, 'q2');
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        1,
      );
      expect(
        container.read(practiceDetailControllerProvider).selectedOptionId,
        isNull,
      );
      expect(
        container.read(practiceDetailControllerProvider).submitted,
        isFalse,
      );
      expect(
        container.read(practiceDetailControllerProvider).isChangingQuestion,
        isTrue,
      );

      // When / Then: 新Route側の処理で初めて進捗保存とq2音源loadを行います。
      await detail.savePreviousProgress(change!);
      await player.loadQuestion(
        change.question,
        speed: change.speed,
        playbackMode: change.playbackMode,
      );
      expect(learning.progress['q1']?.lastContentMode, ContentMode.combined);
      expect(audio.loadedAssets.last, 'audio/q2.mp3');
      expect(audio.lastSpeed, 1.25);
      expect(
        container.read(audioPlayerControllerProvider).activeSentenceId,
        'q2-s1',
      );
    });

    test('2問目から前へ移動し、一時停止中は自動再生を要求しない', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q2');
      await player.loadQuestion(exam.questions[1]);
      await player.togglePlayPause();
      await player.togglePlayPause();
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.paused,
      );

      // When: 再生していない2問目から前へ移動します。
      final change = await detail.changeQuestion(-1, speed: 1);

      // Then: 1問目を選びますが、新画面で再生を開始する指示は渡しません。
      expect(change?.questionId, 'q1');
      expect(change?.resumePlayback, isFalse);
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        0,
      );
      expect(container.read(audioPlayerControllerProvider).questionId, isNull);
      expect(
        container.read(audioPlayerControllerProvider).position,
        Duration.zero,
      );
    });

    test('再生完了後の切り替えでは新しい問題を自動再生しない', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q1');
      await player.loadQuestion(exam.questions.first);
      audio.stateController.add(
        const AudioEngineSnapshot(
          playing: false,
          processing: AudioEngineProcessing.completed,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      // When: completed状態から次問題へ切り替えます。
      final change = await detail.changeQuestion(1, speed: 1);

      // Then: 音源はまだ読み込まず、再生再開の意図だけをfalseで渡します。
      expect(change?.resumePlayback, isFalse);
      expect(audio.playCount, 0);
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.idle,
      );
    });

    test('完了イベント用の切り替えは再生再開を要求し、末尾を必要に応じて折り返す', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q2');
      await player.loadQuestion(exam.questions[1]);

      // When: 順次再生として次問題へ進みます。
      final next = await detail.advanceAfterCompletion(wrap: false, speed: 1);

      // Then: q3を先頭から自動再生する意図をRouteへ渡します。
      expect(next?.questionId, 'q3');
      expect(next?.resumePlayback, isTrue);
      expect(next?.question.audioAssetPath, 'audio/q3.mp3');
      expect(
        container.read(audioPlayerControllerProvider).position,
        Duration.zero,
      );

      detail.completeQuestionChange('q3');
      // When / Then: 末尾では順次再生は停止し、全題ループだけq1へ戻ります。
      expect(
        await detail.advanceAfterCompletion(wrap: false, speed: 1),
        isNull,
      );
      final wrapped = await detail.advanceAfterCompletion(wrap: true, speed: 1);
      expect(wrapped?.questionId, 'q1');
      expect(wrapped?.resumePlayback, isTrue);
      expect(wrapped?.question.audioAssetPath, 'audio/q1.mp3');
    });

    test('範囲外または同じ問題への移動では状態と音源を変更しない', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q1');
      await player.loadQuestion(exam.questions.first);
      final loadCount = audio.loadedAssets.length;

      // When / Then: 先頭より前とPickerの同一問題は何も行いません。
      expect(await detail.changeQuestion(-1, speed: 1), isNull);
      expect(await detail.changeToQuestion('q1', speed: 1), isNull);
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        0,
      );
      expect(container.read(audioPlayerControllerProvider).questionId, 'q1');
      expect(audio.loadedAssets.length, loadCount);
    });

    test('問題一覧の初期化前は切り替え処理を開始しない', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);

      // Given / When: open前の空一覧状態から前後移動を要求します。
      final change = await detail.changeQuestion(1, speed: 1);

      // Then: indexも音源も変更せず、操作lockも開始しません。
      expect(change, isNull);
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        -1,
      );
      expect(
        container.read(practiceDetailControllerProvider).isChangingQuestion,
        isFalse,
      );
      expect(audio.loadedAssets, isEmpty);
    });

    test('切り替え先の音源読込に失敗しても目標問題に留まり、操作lockを解除できる', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q1');
      await player.loadQuestion(exam.questions.first);
      audio.loadErrors['audio/q2.mp3'] = StateError('broken audio');

      // When: Route入力を取得した後、新画面側で次問題の音源読込に失敗します。
      final change = await detail.changeQuestion(1, speed: 1);
      await player.loadQuestion(
        change!.question,
        speed: change.speed,
        playbackMode: change.playbackMode,
      );
      detail.completeQuestionChange(change.questionId);

      // Then: q2本文を保持したままPlayer errorを公開し、戻る操作を再許可します。
      expect(container.read(practiceDetailControllerProvider).questionId, 'q2');
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        1,
      );
      expect(
        container.read(practiceDetailControllerProvider).isChangingQuestion,
        isFalse,
      );
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.error,
      );
    });

    test('stop完了待ちでもRoute入力を即時返し、連打で問題indexを飛ばさない', () async {
      final detail = container.read(practiceDetailControllerProvider.notifier);
      final player = container.read(audioPlayerControllerProvider.notifier);
      await detail.open('q1');
      await player.loadQuestion(exam.questions.first);
      final pendingStop = Completer<void>();
      audio.pendingStop = pendingStop;

      // When: 旧音源のstop完了前に、もう一度「次」を要求します。
      final result = await detail.changeQuestion(1, speed: 1);
      final repeatedChange = await detail.changeQuestion(1, speed: 1);

      // Then: stopを待たずq2を返し、q2のloadは新Routeが開始するまで発生しません。
      expect(repeatedChange, isNull);
      expect(result?.questionId, 'q2');
      expect(
        container.read(practiceDetailControllerProvider).currentQuestionIndex,
        1,
      );
      expect(
        audio.loadedAssets.where((asset) => asset == 'audio/q2.mp3').length,
        0,
      );
      pendingStop.complete();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('AudioPlayerControllerの非同期load', () {
    test('問題切り替えのstop完了後にだけ新音源をloadする', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final questions = buildTestExam(questionCount: 2).questions;
      await controller.loadQuestion(questions[0]);
      await controller.cycleQuestionPlaybackMode();
      final pendingStop = Completer<void>();
      audio.pendingStop = pendingStop;

      // When: stopを開始した直後に、次問題のloadも要求します。
      final stop = controller.beginQuestionChange();
      final load = controller.loadQuestion(
        questions[1],
        playbackMode: QuestionPlaybackMode.repeatAll,
      );
      await Future<void>.delayed(Duration.zero);

      // Then: 表示Stateは即時に操作不可となり、Pluginのloadはstop完了まで始まりません。
      expect(audio.loadedAssets, ['audio/q1.mp3']);
      expect(audio.operationLog, contains('stop:start'));
      expect(audio.operationLog, isNot(contains('load:audio/q2.mp3')));

      pendingStop.complete();
      await Future.wait([stop, load]);
      expect(
        audio.operationLog.indexOf('stop:complete'),
        lessThan(audio.operationLog.indexOf('load:audio/q2.mp3')),
      );
      expect(container.read(audioPlayerControllerProvider).questionId, 'q2');
      expect(
        container.read(audioPlayerControllerProvider).playbackMode,
        QuestionPlaybackMode.repeatAll,
      );
      container.dispose();
      await audio.dispose();
    });

    test('文の4200msへseekし、再生中の状態とactive文を維持する', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      audio.pauseOnSeek = true;
      final question = buildTestExam(questionCount: 1).questions.single
          .copyWith(
            sentences: const [
              TranscriptSentence(
                id: 'q1-s1',
                order: 0,
                textJa: '前半',
                startMs: 0,
                endMs: 4200,
              ),
              TranscriptSentence(
                id: 'q1-s2',
                order: 1,
                textJa: '後半',
                startMs: 4200,
                endMs: 6000,
              ),
            ],
          );
      await controller.loadQuestion(question);
      await controller.togglePlayPause();
      await Future<void>.delayed(Duration.zero);

      await controller.seekToSentence(question.sentences[1]);

      expect(audio.loadedAssets, [question.audioAssetPath]);
      expect(audio.lastSeekPosition, const Duration(milliseconds: 4200));
      expect(audio.seekCount, 1);
      expect(audio.playCount, 2);
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.playing,
      );
      expect(
        container.read(audioPlayerControllerProvider).activeSentenceId,
        'q1-s2',
      );
      container.dispose();
      await audio.dispose();
    });

    test('一時停止中と再生完了後は文seekで自動再生しない', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final question = buildTestExam(questionCount: 1).questions.single;
      await controller.loadQuestion(question);
      await controller.togglePlayPause();
      await controller.togglePlayPause();
      await Future<void>.delayed(Duration.zero);
      final playCount = audio.playCount;

      await controller.seekToSentence(question.sentences.single);
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.paused,
      );
      expect(audio.playCount, playCount);

      audio.stateController.add(
        const AudioEngineSnapshot(
          playing: false,
          processing: AudioEngineProcessing.completed,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await controller.seekToSentence(question.sentences.single);
      expect(
        container.read(audioPlayerControllerProvider).status,
        AudioPlayerStatus.paused,
      );
      expect(audio.playCount, playCount);
      container.dispose();
      await audio.dispose();
    });

    test('null・負数・音源長超過・別問題の文ではseekしない', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      const currentQuestionSentences = [
        TranscriptSentence(id: 'null', order: 0, textJa: '時間なし'),
        TranscriptSentence(
          id: 'negative',
          order: 1,
          textJa: '負数',
          startMs: -1,
          endMs: 100,
        ),
        TranscriptSentence(
          id: 'too-late',
          order: 2,
          textJa: '範囲外',
          startMs: 31000,
          endMs: 32000,
        ),
      ];
      final question = buildTestExam(
        questionCount: 1,
      ).questions.single.copyWith(sentences: currentQuestionSentences);
      await controller.loadQuestion(question);
      for (final sentence in currentQuestionSentences) {
        await controller.seekToSentence(sentence);
      }
      await controller.seekToSentence(
        const TranscriptSentence(
          id: 'other-question',
          order: 0,
          textJa: '別問題',
          startMs: 0,
          endMs: 1000,
        ),
      );

      expect(audio.seekCount, 0);
      container.dispose();
      await audio.dispose();
    });

    test('音源load完了前は時間付き文でもseekしない', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final question = buildTestExam(questionCount: 1).questions.single;
      final pending = Completer<Duration>();
      audio.pendingLoads[question.audioAssetPath] = pending;
      final load = controller.loadQuestion(question);
      await Future<void>.delayed(Duration.zero);

      await controller.seekToSentence(question.sentences.single);

      expect(audio.seekCount, 0);
      pending.complete(const Duration(seconds: 30));
      await load;
      container.dispose();
      await audio.dispose();
    });

    test('文時間がない問題でも問題単位の3つの再生modeを切り替えられる', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final question = buildTestExam(questionCount: 1).questions.single
          .copyWith(
            sentences: const [
              TranscriptSentence(id: 'q1-s1', order: 0, textJa: '時間なし本文'),
            ],
          );
      await controller.loadQuestion(question);

      // When: 時刻を持たない文のseekと問題単位のmode切り替えを要求します。
      await controller.seekToSentence(question.sentences.single);
      await controller.cycleQuestionPlaybackMode();

      // Then: 文seekは発生せず、順次再生から全題ループへ切り替わります。
      expect(audio.seekCount, 0);
      expect(
        container.read(audioPlayerControllerProvider).activeSentenceId,
        isNull,
      );
      expect(
        container.read(audioPlayerControllerProvider).playbackMode,
        QuestionPlaybackMode.repeatAll,
      );
      expect(audio.questionLooping, isFalse);

      await controller.cycleQuestionPlaybackMode();
      expect(
        container.read(audioPlayerControllerProvider).playbackMode,
        QuestionPlaybackMode.repeatCurrent,
      );
      expect(audio.questionLooping, isTrue);

      await controller.cycleQuestionPlaybackMode();
      expect(
        container.read(audioPlayerControllerProvider).playbackMode,
        QuestionPlaybackMode.sequential,
      );
      expect(audio.questionLooping, isFalse);
      container.dispose();
      await audio.dispose();
    });

    test('古いloadが後から完了しても新しい問題を上書きしない', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final questions = buildTestExam(questionCount: 2).questions;
      final firstPending = Completer<Duration>();
      final secondPending = Completer<Duration>();
      audio.pendingLoads[questions[0].audioAssetPath] = firstPending;
      audio.pendingLoads[questions[1].audioAssetPath] = secondPending;

      // Given: q1のload完了前にq2のloadを開始します。
      final firstLoad = controller.loadQuestion(questions[0]);
      await Future<void>.delayed(Duration.zero);
      final secondLoad = controller.loadQuestion(questions[1]);
      await Future<void>.delayed(Duration.zero);

      // When: 新しいq2を先に、古いq1を後から完了させます。
      secondPending.complete(const Duration(seconds: 22));
      await secondLoad;
      firstPending.complete(const Duration(seconds: 11));
      await firstLoad;

      // Then: 公開Stateは最後に要求したq2のままです。
      expect(container.read(audioPlayerControllerProvider).questionId, 'q2');
      expect(
        container.read(audioPlayerControllerProvider).duration,
        const Duration(seconds: 22),
      );
      container.dispose();
      await audio.dispose();
    });

    test('Provider破棄後に保留中loadが完了しても例外を発生させない', () async {
      final audio = FakeAudioPlaybackService();
      final container = ProviderContainer(
        overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      );
      final controller = container.read(audioPlayerControllerProvider.notifier);
      final question = buildTestExam(questionCount: 1).questions.single;
      final pending = Completer<Duration>();
      audio.pendingLoads[question.audioAssetPath] = pending;
      final load = controller.loadQuestion(question);
      await Future<void>.delayed(Duration.zero);

      // When: Providerを破棄してからPlugin相当の非同期処理を完了させます。
      container.dispose();
      pending.complete(const Duration(seconds: 10));

      // Then: 破棄済みNotifierへStateを書き戻さず、Futureは正常終了します。
      await expectLater(load, completes);
      await audio.dispose();
    });
  });
}
