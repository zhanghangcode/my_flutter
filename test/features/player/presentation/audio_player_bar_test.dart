import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/player/data/audio_playback_service.dart';
import 'package:nihongo_listening/features/player/presentation/audio_player_bar.dart';

import '../../../helpers/practice_test_fakes.dart';

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
}

Future<void> _pumpBar(
  WidgetTester tester, {
  required FakeAudioPlaybackService audio,
  required bool showPrevious,
  required bool showNext,
  bool navigationEnabled = true,
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
              onPreviousQuestion: onPrevious ?? () {},
              onNextQuestion: onNext ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}
