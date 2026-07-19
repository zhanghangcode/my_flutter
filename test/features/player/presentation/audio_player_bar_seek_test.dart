import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/player/presentation/audio_player_bar.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/presentation/widgets/transcript_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/practice_test_fakes.dart';

/// SeekBar操作からTranscriptのactive文同期までを検証するWidgetテスト群です。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('再生中にSeekBarをドラッグすると、離した位置で1回だけseekしactive文を更新して再生を継続する', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final audio = FakeAudioPlaybackService();
    final container = ProviderContainer(
      overrides: [
        audioPlaybackServiceProvider.overrideWithValue(audio),
        learningRepositoryProvider.overrideWithValue(FakeLearningRepository()),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(audio.dispose);

    final question = _timedQuestion();
    final controller = container.read(audioPlayerControllerProvider.notifier);
    await controller.loadQuestion(question);
    // Given: 音声が再生中の状態にします。
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: true,
        processing: AudioEngineProcessing.ready,
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: TranscriptList(question: question)),
                AudioPlayerBar(
                  showPreviousQuestion: false,
                  showNextQuestion: false,
                  questionNavigationEnabled: true,
                  interactionEnabled: true,
                  onPreviousQuestion: () {},
                  onNextQuestion: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // When: SeekBarをドラッグ中の途中経過(onChanged)を複数回発生させ、
    // 最後に指を離した位置(onChangeEnd)で確定させます。
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(1000);
    await tester.pump();
    slider.onChanged?.call(3000);
    await tester.pump();

    // Then: ドラッグ中はまだ実機へのseekを発行しません。
    expect(audio.seekCount, 0);

    slider.onChangeEnd?.call(4200);
    await tester.pump();

    // Then: 指を離した瞬間の位置だけで1回seekし、対応する後半の文がactiveになります。
    expect(audio.seekCount, 1);
    expect(audio.lastSeekPosition, const Duration(milliseconds: 4200));
    expect(
      container.read(audioPlayerControllerProvider).activeSentenceId,
      'q1_s002',
    );
    expect(
      tester.widget<Text>(find.text('後半の文章')).style?.color,
      AppColors.accent,
    );
    final tileDecoration =
        tester
                .widget<AnimatedContainer>(
                  find.ancestor(
                    of: find.text('後半の文章'),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect((tileDecoration.border as Border).left.color, AppColors.accent);

    // Then: seek前の再生中状態を維持します(自動で一時停止しません)。
    expect(container.read(audioPlayerControllerProvider).isPlaying, isTrue);
  });

  testWidgets('一時停止中にSeekBarを操作すると、位置だけ変更し一時停止状態を維持する', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final audio = FakeAudioPlaybackService();
    final container = ProviderContainer(
      overrides: [
        audioPlaybackServiceProvider.overrideWithValue(audio),
        learningRepositoryProvider.overrideWithValue(FakeLearningRepository()),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(audio.dispose);

    final question = _timedQuestion();
    final controller = container.read(audioPlayerControllerProvider.notifier);
    await controller.loadQuestion(question);
    // Given: 一時停止中の状態にします(playing:false)。

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                Expanded(child: TranscriptList(question: question)),
                AudioPlayerBar(
                  showPreviousQuestion: false,
                  showNextQuestion: false,
                  questionNavigationEnabled: true,
                  interactionEnabled: true,
                  onPreviousQuestion: () {},
                  onNextQuestion: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged?.call(4200);
    slider.onChangeEnd?.call(4200);
    await tester.pump();

    // Then: 位置とactive文だけを更新し、一時停止状態のまま維持します。
    expect(audio.seekCount, 1);
    expect(
      container.read(audioPlayerControllerProvider).activeSentenceId,
      'q1_s002',
    );
    expect(container.read(audioPlayerControllerProvider).isPlaying, isFalse);
  });
}

/// SeekBar操作の検証に使う、時間情報を持つ最小問題を生成します。
Question _timedQuestion() => const Question(
  id: 'q1',
  examId: 'exam',
  section: 1,
  number: 1,
  type: '課題理解',
  promptJa: '問題文',
  options: [],
  audioAssetPath: 'assets/audio/q1.mp3',
  sentences: [
    TranscriptSentence(
      id: 'q1_s001',
      order: 0,
      textJa: '前半の文章',
      startMs: 0,
      endMs: 4200,
    ),
    TranscriptSentence(
      id: 'q1_s002',
      order: 1,
      textJa: '後半の文章',
      startMs: 4200,
      endMs: 6000,
    ),
  ],
);
