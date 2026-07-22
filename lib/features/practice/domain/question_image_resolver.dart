import 'practice_models.dart';
import 'question_image_source.dart';

/// 問題・選択肢の教材メタデータから実際に表示するAsset/Fileを決定する境界。
///
/// [Question.hasImage]が`true`の問題、または[AnswerOption.hasImage]が`true`の
/// 選択肢に対してのみ呼び出されることを前提とします。
abstract interface class QuestionImageResolver {
  /// [question]の配送方式とLocal Manifestを確認し、表示可能な図版を返します。
  Future<QuestionImageSource> resolve(Question question);

  /// [question]に属する[option]自体の図版を、配送方式とLocal Manifestを確認して
  /// 返します。
  Future<QuestionImageSource> resolveOption(
    Question question,
    AnswerOption option,
  );
}

/// 図版を安全に解決できない場合に、画面表示可能な理由を通知します。
class QuestionImageUnavailableException implements Exception {
  /// 利用者向けの[message]を保持します。
  const QuestionImageUnavailableException(this.message);

  /// 絶対pathや内部例外を含まない利用者向けメッセージです。
  final String message;

  @override
  String toString() => message;
}
