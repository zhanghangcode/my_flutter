import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/app/theme.dart';
import 'package:nihongo_listening/features/practice/application/question_image_provider.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/domain/question_image_resolver.dart';
import 'package:nihongo_listening/features/practice/domain/question_image_source.dart';
import 'package:nihongo_listening/features/practice/presentation/widgets/question_image.dart';

/// QuestionImageの表示・読込・エラー状態と、Provider経由の解決結果を検証します。
///
/// 実Local Fileを`Image.file`で描画する検証はflutter_testのfake時計内では
/// 完了しない実isolate依存のdecodeを伴うため行わず、Provider層の解決結果だけを
/// `ProviderContainer`で直接確認します。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('画像を持たない問題は何も表示しない', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: QuestionImage(question: _question())),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('画像の解決に失敗した場合はエラー文言を表示する', (tester) async {
    final resolver = _FakeQuestionImageResolver(
      null,
      error: const QuestionImageUnavailableException('画像データがダウンロードされていません。'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [questionImageResolverProvider.overrideWithValue(resolver)],
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: QuestionImage(
              question: _question(imageAssetPath: 'assets/images/q1.jpg'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('画像を読み込めませんでした。'), findsOneWidget);
  });

  test('画像を持つ問題はquestionImageSourceProviderがLocal Fileを解決する', () async {
    final resolver = _FakeQuestionImageResolver(
      const QuestionImageSource.file('/local/downloads/q1.jpg'),
    );
    final container = ProviderContainer(
      overrides: [questionImageResolverProvider.overrideWithValue(resolver)],
    );
    addTearDown(container.dispose);

    final question = _question(imageAssetPath: 'assets/images/q1.jpg');
    final source = await container.read(
      questionImageSourceProvider(question).future,
    );

    expect(source, const QuestionImageSource.file('/local/downloads/q1.jpg'));
    expect(source.isFile, isTrue);
  });
}

/// resolve結果またはエラーを固定で返すテスト用Resolver。
class _FakeQuestionImageResolver implements QuestionImageResolver {
  /// [source]を成功結果、[error]を送出する任意の失敗として保持します。
  _FakeQuestionImageResolver(this.source, {this.error});

  /// resolve成功時に返す図版です。
  final QuestionImageSource? source;

  /// 非`null`の場合にresolveから送出する例外です。
  final Object? error;

  @override
  Future<QuestionImageSource> resolve(Question question) async {
    final failure = error;
    if (failure != null) throw failure;
    return source!;
  }
}

/// テスト対象のWidgetへ渡す最小限の問題データを生成します。
Question _question({String? imageAssetPath}) => Question(
  id: 'q1',
  examId: 'exam',
  section: 1,
  number: 1,
  type: 'demo',
  promptJa: '問題1',
  options: const [],
  audioAssetPath: 'assets/audio/q1.mp3',
  sentences: const [],
  imageAssetPath: imageAssetPath,
);
