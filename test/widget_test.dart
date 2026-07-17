import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/app.dart';

void main() {
  testWidgets('app starts with the practice destination', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NihongoListeningApp()));
    await tester.pump();

    expect(find.text('練習'), findsWidgets);
    expect(find.text('テスト'), findsOneWidget);
    expect(find.text('お気に入り'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
