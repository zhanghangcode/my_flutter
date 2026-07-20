import '../../player/domain/audio_resource_resolver.dart';
import '../../player/domain/audio_source_location.dart';
import '../../practice/domain/practice_models.dart';
import '../../practice/domain/practice_repository.dart';
import '../domain/download_repository.dart';

/// 教材metadataとLocal Manifestを照合して音源の保存場所を決定するResolver。
class LocalAudioResourceResolver implements AudioResourceResolver {
  /// 教材RepositoryとDownload Repositoryを注入して生成します。
  const LocalAudioResourceResolver(
    this._practiceRepository,
    this._downloadRepository,
  );

  /// 試験metadataと問題一覧を読み込むRepositoryです。
  final PracticeRepository _practiceRepository;

  /// Download ManifestとLocal Fileを検証するRepositoryです。
  final DownloadRepository _downloadRepository;

  @override
  Future<AudioSourceLocation> resolve(Question question) async {
    final summaries = await _practiceRepository.getExams();
    final matches = summaries.where((item) => item.id == question.examId);
    if (matches.length != 1) {
      throw const AudioResourceUnavailableException('音声データの教材情報を確認できません。');
    }
    final summary = matches.single;
    if (summary.audioDeliveryMode == AudioDeliveryMode.bundled) {
      return AudioSourceLocation.asset(question.audioAssetPath);
    }

    final resource = await _practiceRepository.getExam(summary.id);
    final localPath = await _downloadRepository.resolveLocalAudioPath(
      summary,
      resource,
      question,
    );
    if (localPath == null) {
      throw const AudioResourceUnavailableException('音声データがダウンロードされていません。');
    }
    return AudioSourceLocation.file(localPath);
  }
}
