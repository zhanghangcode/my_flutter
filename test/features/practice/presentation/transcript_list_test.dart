import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/providers.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/presentation/widgets/transcript_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/practice_test_fakes.dart';

/// Transcript のタップ seek とアクティブ文表示を検証する Widget テスト群です。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('時間付き文をタップすると1回seekしactive表示を更新する', (
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
    final question = _timedQuestion();
    await container
        .read(audioPlayerControllerProvider.notifier)
        .loadQuestion(question);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: TranscriptList(question: question)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('後半の文章'));
    await tester.pump();

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

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await audio.dispose();
  });

  testWidgets('時間なし文は表示するがタップしてもseekしない', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final audio = FakeAudioPlaybackService();
    final container = ProviderContainer(
      overrides: [
        audioPlaybackServiceProvider.overrideWithValue(audio),
        learningRepositoryProvider.overrideWithValue(FakeLearningRepository()),
      ],
    );
    final question = _timedQuestion().copyWith(
      sentences: const [
        TranscriptSentence(id: 'q1_s001', order: 0, textJa: '時間なしの文章'),
      ],
    );
    await container
        .read(audioPlayerControllerProvider.notifier)
        .loadQuestion(question);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: TranscriptList(question: question)),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('時間なしの文章'));
    await tester.pump();

    expect(audio.seekCount, 0);
    expect(
      container.read(audioPlayerControllerProvider).activeSentenceId,
      isNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
    await audio.dispose();
  });
}

/// 文タップとアクティブ表示の検証に使う、時間情報を持つ最小問題を生成します。
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
