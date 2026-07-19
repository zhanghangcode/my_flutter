import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/splash/presentation/splash_page.dart';

/// SplashPage の破棄安全性と Animation 低減時の表示を検証する Widget テスト群です。
void main() {
  testWidgets('disposing splash before startup completion is safe', (
    tester,
  ) async {
    // Given: SplashPageを表示し、Animationと起動待機を開始します。
    await tester.pumpWidget(
      MaterialApp(theme: buildDarkTheme(), home: const SplashPage()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // When: 最低表示時間の完了前にWidgetツリーからSplashPageを破棄します。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    // Then: AnimationControllerの破棄漏れやdispose後のnavigationが発生しません。
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion shows splash content without animation', (
    tester,
  ) async {
    // Given: OSのAnimation低減設定をMediaQueryへ反映します。
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SplashPage(),
        ),
      ),
    );

    // Then: Animationの進行を待たずに主要なブランド文言を確認できます。
    expect(find.text('聴解トレーニング'), findsOneWidget);
    expect(find.text('聴いて、読んで、身につける'), findsOneWidget);

    // 起動待機が完了する前に破棄し、GoRouterを持たないテスト環境での遷移を防ぎます。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
