import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/app.dart';

/// アプリ起動時の Splash 表示と練習画面への遷移を検証する Widget テスト群です。
void main() {
  testWidgets('app shows splash before opening the practice destination', (
    tester,
  ) async {
    // Given: 本番と同じく ProviderScope 配下へルート Widget を配置します。
    // WidgetTester.pumpWidget はテスト用の Widget ツリーを構築します。
    await tester.pumpWidget(const ProviderScope(child: NihongoListeningApp()));

    // Then: Flutterの初期RouteとしてSplashの文言を表示します。
    expect(find.text('聴解トレーニング'), findsOneWidget);
    expect(find.text('聴いて、読んで、身につける'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // When: 最低表示時間の直前まで仮想時間を進めます。
    await tester.pump(const Duration(milliseconds: 999));

    // Then: 一瞬だけ表示されることなく、Splashが維持されます。
    expect(find.text('聴解トレーニング'), findsOneWidget);

    // When: 1,000ms到達後の遷移とFade Transitionを完了させます。
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    // Then: Splashを置換し、4つのNavigationDestinationを表示します。
    expect(find.text('聴解トレーニング'), findsNothing);
    expect(find.text('練習'), findsWidgets);
    expect(find.text('テスト'), findsOneWidget);
    expect(find.text('お気に入り'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);

    // When: rootの練習画面でsystem backを発行します。
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Then: goで置換されたSplashは履歴に残っていません。
    expect(find.text('聴解トレーニング'), findsNothing);
    expect(find.text('練習'), findsWidgets);
  });
}
