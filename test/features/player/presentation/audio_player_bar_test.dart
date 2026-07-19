import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/player/presentation/audio_player_bar.dart';

import '../../../helpers/practice_test_fakes.dart';

/// AudioPlayerBar の問題移動ボタンと操作可否を検証する Widget テスト群です。
void main() {
  testWidgets('問題位置に応じて前後ボタンだけを表示する', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);

    // Given: 先頭問題として左だけを非表示にします。
    await _pumpBar(tester, audio: audio, showPrevious: false, showNext: true);
    final firstPlayCenter = tester.getCenter(find.byIcon(Icons.play_arrow));

    // Then: 非表示側にはTooltipも操作対象も残さず、次問題だけを表示します。
    expect(find.byTooltip('前の問題'), findsNothing);
    expect(find.byTooltip('次の問題'), findsOneWidget);

    // When: 中央問題として左右を表示します。
    await _pumpBar(tester, audio: audio, showPrevious: true, showNext: true);
    final middlePlayCenter = tester.getCenter(find.byIcon(Icons.play_arrow));

    // Then: 固定幅slotにより中央の再生ボタン位置は変わりません。
    expect(find.byTooltip('前の問題'), findsOneWidget);
    expect(find.byTooltip('次の問題'), findsOneWidget);
    expect(middlePlayCenter, firstPlayCenter);

    // When / Then: 末尾では右だけを非表示にしても中央位置を維持します。
    await _pumpBar(tester, audio: audio, showPrevious: true, showNext: false);
    expect(find.byTooltip('前の問題'), findsOneWidget);
    expect(find.byTooltip('次の問題'), findsNothing);
    expect(tester.getCenter(find.byIcon(Icons.play_arrow)), firstPlayCenter);
  });

  testWidgets('0問または1問では前後操作を生成しない', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    var previousCount = 0;
    var nextCount = 0;

    // Given / When: 前後問題が存在しない境界状態を表示します。
    await _pumpBar(
      tester,
      audio: audio,
      showPrevious: false,
      showNext: false,
      onPrevious: () => previousCount++,
      onNext: () => nextCount++,
    );

    // Then: 非表示slotにはIcon、Tooltip、タップ判定がありません。
    expect(find.byIcon(Icons.skip_previous), findsNothing);
    expect(find.byIcon(Icons.skip_next), findsNothing);
    expect(find.byTooltip('前の問題'), findsNothing);
    expect(find.byTooltip('次の問題'), findsNothing);
    expect(previousCount, 0);
    expect(nextCount, 0);
  });

  testWidgets('表示中の前後ボタンは指定callbackを呼び出す', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    var previousCount = 0;
    var nextCount = 0;
    await _pumpBar(
      tester,
      audio: audio,
      showPrevious: true,
      showNext: true,
      onPrevious: () => previousCount++,
      onNext: () => nextCount++,
    );

    // When: 左右の問題切り替えボタンを1回ずつ操作します。
    await tester.tap(find.byTooltip('前の問題'));
    await tester.tap(find.byTooltip('次の問題'));

    // Then: 文移動ではなく、画面から渡された問題切り替えcallbackだけを実行します。
    expect(previousCount, 1);
    expect(nextCount, 1);
  });

  testWidgets('再生中と一時停止中はすべてのPlayer操作を有効にする', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    final question = buildTestExam(questionCount: 1).questions.single;
    await _pumpBar(tester, audio: audio, showPrevious: true, showNext: true);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AudioPlayerBar)),
    );
    final controller = container.read(audioPlayerControllerProvider.notifier);
    await controller.loadQuestion(question);

    // Given: 音源が再生中でもPlayerの全操作を有効にします。
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: true,
        processing: AudioEngineProcessing.ready,
      ),
    );
    await tester.pump();
    _expectPlayerControlsEnabled(tester, playing: true);

    // When / Then: 一時停止へ変わっても同じ操作を有効に保ちます。
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.ready,
      ),
    );
    await tester.pump();
    _expectPlayerControlsEnabled(tester, playing: false);

    // Then: 再生完了後も先頭からの再生と各操作を有効に保ちます。
    audio.stateController.add(
      const AudioEngineSnapshot(
        playing: false,
        processing: AudioEngineProcessing.completed,
      ),
    );
    await tester.pump();
    _expectPlayerControlsEnabled(tester, playing: false);
  });

  testWidgets('問題切り替え中は表示中の前後ボタンを無効化する', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    var operationCount = 0;
    await _pumpBar(
      tester,
      audio: audio,
      showPrevious: true,
      showNext: true,
      navigationEnabled: false,
      onPrevious: () => operationCount++,
      onNext: () => operationCount++,
    );

    // When: 無効化された左右ボタンの位置をtapします。
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.tap(find.byIcon(Icons.skip_next));

    // Then: 見た目は維持してもcallbackは実行せず、多重切り替えを防ぎます。
    expect(operationCount, 0);
  });

  testWidgets('問題切り替え中は読み込み表示を出さず、Player操作を無効化する', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    final pending = Completer<Duration>();
    final question = buildTestExam(questionCount: 1).questions.single;
    audio.pendingLoads[question.audioAssetPath] = pending;
    await _pumpBar(
      tester,
      audio: audio,
      showPrevious: false,
      showNext: false,
      interactionEnabled: false,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AudioPlayerBar)),
    );
    final load = container
        .read(audioPlayerControllerProvider.notifier)
        .loadQuestion(question);
    await tester.pump();

    // Then: 全画面overlayに代わるSpinnerをPlayer内にも表示しません。
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    expect(
      tester
          .widget<PopupMenuButton<double>>(find.byType(PopupMenuButton<double>))
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.play_arrow))
          .onPressed,
      isNull,
    );

    pending.complete(const Duration(seconds: 30));
    await load;
  });

  testWidgets('右下ボタンで順次再生・全問題ループ・単一問題ループを切り替える', (tester) async {
    final audio = FakeAudioPlaybackService();
    addTearDown(audio.dispose);
    await _pumpBar(tester, audio: audio, showPrevious: false, showNext: false);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AudioPlayerBar)),
    );
    await container
        .read(audioPlayerControllerProvider.notifier)
        .loadQuestion(buildTestExam(questionCount: 1).questions.single);
    await tester.pump();

    // Given: 初期状態では、問題を順番に再生して末尾で停止します。
    expect(find.byTooltip('問題を順番に再生'), findsOneWidget);
    expect(find.byIcon(Icons.playlist_play), findsOneWidget);

    // When / Then: 1回目で全問題ループへ切り替えます。
    await tester.tap(find.byTooltip('問題を順番に再生'));
    await tester.pump();
    expect(find.byTooltip('すべての問題を繰り返す'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(audio.questionLooping, isFalse);

    // When / Then: 2回目は現在の問題だけをPlugin側でループします。
    await tester.tap(find.byTooltip('すべての問題を繰り返す'));
    await tester.pump();
    expect(find.byTooltip('現在の問題を繰り返す'), findsOneWidget);
    expect(find.byIcon(Icons.repeat_one), findsOneWidget);
    expect(audio.questionLooping, isTrue);

    // When / Then: 3回目で順次再生へ戻り、単一音源のloopを解除します。
    await tester.tap(find.byTooltip('現在の問題を繰り返す'));
    await tester.pump();
    expect(find.byTooltip('問題を順番に再生'), findsOneWidget);
    expect(audio.questionLooping, isFalse);
  });
}

/// [playing] の状態にかかわらず、すべての通常プレイヤー操作が有効かを確認します。
void _expectPlayerControlsEnabled(
  WidgetTester tester, {
  required bool playing,
}) {
  expect(
    tester
        .widget<IconButton>(
          find.widgetWithIcon(
            IconButton,
            playing ? Icons.pause : Icons.play_arrow,
          ),
        )
        .onPressed,
    isNotNull,
  );
  expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
  expect(
    tester
        .widget<PopupMenuButton<double>>(find.byType(PopupMenuButton<double>))
        .enabled,
    isTrue,
  );
  expect(
    tester
        .widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.skip_previous),
        )
        .onPressed,
    isNotNull,
  );
  expect(
    tester
        .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.skip_next))
        .onPressed,
    isNotNull,
  );
  expect(
    tester
        .widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.playlist_play),
        )
        .onPressed,
    isNotNull,
  );
}

/// テスト条件に応じた [AudioPlayerBar] を ProviderScope 配下へ配置します。
///
/// 問題移動の表示境界、操作可否、callback を個別に指定できるようにしています。
Future<void> _pumpBar(
  WidgetTester tester, {
  required FakeAudioPlaybackService audio,
  required bool showPrevious,
  required bool showNext,
  bool navigationEnabled = true,
  bool interactionEnabled = true,
  VoidCallback? onPrevious,
  VoidCallback? onNext,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [audioPlaybackServiceProvider.overrideWithValue(audio)],
      child: MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AudioPlayerBar(
              showPreviousQuestion: showPrevious,
              showNextQuestion: showNext,
              questionNavigationEnabled: navigationEnabled,
              interactionEnabled: interactionEnabled,
              onPreviousQuestion: onPrevious ?? () {},
              onNextQuestion: onNext ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}
