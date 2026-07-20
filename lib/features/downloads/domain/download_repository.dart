import '../../practice/domain/practice_models.dart';
import 'download_state.dart';

/// Local Manifestと実ファイルを照合した試験音声の検査結果。
class DownloadInspection {
  /// 検査結果を生成します。
  const DownloadInspection({
    required this.status,
    this.localAudioPaths = const {},
    this.resourceVersion = 0,
  });

  /// 永続化状態と実ファイルを照合した結果です。
  final DownloadStatus status;

  /// questionIdをキーとする検証済みLocal Fileの絶対pathです。
  final Map<String, String> localAudioPaths;

  /// 検証済みの音声リソースversionです。
  final int resourceVersion;

  /// Local Fileから安全に再生できる場合に`true`を返します。
  bool get isDownloaded => status == DownloadStatus.downloaded;
}

/// 利用者向けメッセージと原因を分離して通知するDownload例外。
class ExamDownloadException implements Exception {
  /// [message]を画面表示可能な内容として保持します。
  const ExamDownloadException(this.message);

  /// 絶対pathなどの内部情報を含まない利用者向けメッセージです。
  final String message;

  @override
  String toString() => message;
}

/// 試験音声のダウンロード・保存・検証を担うRepositoryの抽象化。
///
/// Widgetはこのinterfaceだけに依存し、Mock/Server切り替えやLocal Storageの
/// 実装詳細を意識しません。
abstract interface class DownloadRepository {
  /// [exam]に必要な音声がすべてLocal Directoryに実在し、サイズも妥当かを確認します。
  ///
  /// 永続化されたflagだけを信用せず、必ずファイルシステムを確認します。
  Future<DownloadInspection> inspect(
    ExamSummary summary,
    ExamResource resource,
  );

  /// [exam]の音声をDownload Sourceから取得してLocal Directoryへ保存します。
  ///
  /// [onProgress]には`0.0`〜`1.0`の完了割合を順に通知します。保存後は
  /// [isDownloaded]と同じ基準で検証し、不完全な場合は例外を送出します。
  Future<DownloadInspection> download(
    ExamSummary summary,
    ExamResource resource, {
    required void Function(double progress) onProgress,
  });

  /// 検証済みManifestから[question]に対応するLocal File pathを返します。
  ///
  /// Manifestまたは実ファイルが不完全な場合は`null`を返し、Assetへはfallbackしません。
  Future<String?> resolveLocalAudioPath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  );
}
