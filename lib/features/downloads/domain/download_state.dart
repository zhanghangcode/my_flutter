/// 試験単位の音声ダウンロード進行状況。
enum DownloadStatus {
  /// 端末に音声が保存されていない、または未確認の状態です。
  notDownloaded,

  /// Mock/Server Downloadが進行中の状態です。
  downloading,

  /// 音声がLocal Directoryへ保存され、検証済みの状態です。
  downloaded,

  /// ダウンロードまたは検証に失敗した状態です。
  failed,
}

/// 1試験分の音声ダウンロード状態を表す immutable value。
///
/// UIはこの値だけを参照すればよく、実際のファイルI/OやRepository実装を
/// 意識しません。
class ExamDownloadState {
  const ExamDownloadState._({
    required this.status,
    this.progress = 0,
    this.errorMessage,
    this.localAudioPaths = const {},
    this.localImagePaths = const {},
    this.resourceVersion = 0,
  });

  /// 未ダウンロードまたは未確認の初期状態を生成します。
  const ExamDownloadState.notDownloaded()
    : this._(status: DownloadStatus.notDownloaded);

  /// ダウンロード進行中の状態を生成します。
  ///
  /// [progress]は`0.0`〜`1.0`の完了割合です。
  const ExamDownloadState.downloading({required double progress})
    : this._(status: DownloadStatus.downloading, progress: progress);

  /// 保存・検証まで完了した状態を生成します。
  const ExamDownloadState.downloaded({
    required Map<String, String> localAudioPaths,
    Map<String, String> localImagePaths = const {},
    required int resourceVersion,
  }) : this._(
         status: DownloadStatus.downloaded,
         progress: 1,
         localAudioPaths: localAudioPaths,
         localImagePaths: localImagePaths,
         resourceVersion: resourceVersion,
       );

  /// ダウンロードまたは検証に失敗した状態を生成します。
  ///
  /// [message]は画面へ表示できる失敗内容です。
  const ExamDownloadState.failed(String message)
    : this._(status: DownloadStatus.failed, errorMessage: message);

  /// 現在のダウンロード進行状況です。
  final DownloadStatus status;

  /// ダウンロード中の完了割合（`0.0`〜`1.0`）です。完了後は`1`のままです。
  final double progress;

  /// 失敗時の内容です。失敗していない場合は`null`です。
  final String? errorMessage;

  /// questionIdをキーとする検証済みLocal Fileの絶対pathです。
  final Map<String, String> localAudioPaths;

  /// 画像を持つ問題のquestionIdをキーとする検証済みLocal Fileの絶対pathです。
  final Map<String, String> localImagePaths;

  /// 現在のLocal Manifestで検証済みの音声リソースversionです。
  final int resourceVersion;

  /// 検証済みでLocal再生可能な状態かを返します。
  bool get isDownloaded => status == DownloadStatus.downloaded;

  /// ダウンロードが進行中かを返します。
  bool get isDownloading => status == DownloadStatus.downloading;

  /// 直前の試行が失敗した状態かを返します。
  bool get isFailed => status == DownloadStatus.failed;
}
