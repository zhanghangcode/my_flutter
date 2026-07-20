import '../../practice/domain/practice_models.dart';
import 'audio_source_location.dart';

/// 問題の教材メタデータから実際に再生するAsset/Fileを決定する境界。
abstract interface class AudioResourceResolver {
  /// [question]の配送方式とLocal Manifestを確認し、再生可能な音源を返します。
  Future<AudioSourceLocation> resolve(Question question);
}

/// 音源を安全に解決できない場合に、画面表示可能な理由を通知します。
class AudioResourceUnavailableException implements Exception {
  /// 利用者向けの[message]を保持します。
  const AudioResourceUnavailableException(this.message);

  /// 絶対pathや内部例外を含まない利用者向けメッセージです。
  final String message;

  @override
  String toString() => message;
}
