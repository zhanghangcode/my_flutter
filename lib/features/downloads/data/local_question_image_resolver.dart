import '../../practice/domain/practice_models.dart';
import '../../practice/domain/practice_repository.dart';
import '../../practice/domain/question_image_resolver.dart';
import '../../practice/domain/question_image_source.dart';
import '../domain/download_repository.dart';

/// 教材metadataとLocal Manifestを照合して問題図版の保存場所を決定するResolver。
class LocalQuestionImageResolver implements QuestionImageResolver {
  /// 教材RepositoryとDownload Repositoryを注入して生成します。
  const LocalQuestionImageResolver(
    this._practiceRepository,
    this._downloadRepository,
  );

  /// 試験metadataと問題一覧を読み込むRepositoryです。
  final PracticeRepository _practiceRepository;

  /// Download ManifestとLocal Fileを検証するRepositoryです。
  final DownloadRepository _downloadRepository;

  @override
  Future<QuestionImageSource> resolve(Question question) async {
    final imageAssetPath = question.imageAssetPath;
    if (imageAssetPath == null) {
      throw const QuestionImageUnavailableException('この問題には画像がありません。');
    }
    final summary = await _findSummary(question.examId);
    if (summary.audioDeliveryMode == AudioDeliveryMode.bundled) {
      return QuestionImageSource.asset(imageAssetPath);
    }

    final resource = await _practiceRepository.getExam(summary.id);
    final localPath = await _downloadRepository.resolveLocalImagePath(
      summary,
      resource,
      question,
    );
    if (localPath == null) {
      throw const QuestionImageUnavailableException('画像データがダウンロードされていません。');
    }
    return QuestionImageSource.file(localPath);
  }

  @override
  Future<QuestionImageSource> resolveOption(
    Question question,
    AnswerOption option,
  ) async {
    final imageAssetPath = option.imageAssetPath;
    if (imageAssetPath == null) {
      throw const QuestionImageUnavailableException('この選択肢には画像がありません。');
    }
    final summary = await _findSummary(question.examId);
    if (summary.audioDeliveryMode == AudioDeliveryMode.bundled) {
      return QuestionImageSource.asset(imageAssetPath);
    }

    final resource = await _practiceRepository.getExam(summary.id);
    final localPath = await _downloadRepository.resolveLocalOptionImagePath(
      summary,
      resource,
      question,
      option,
    );
    if (localPath == null) {
      throw const QuestionImageUnavailableException('画像データがダウンロードされていません。');
    }
    return QuestionImageSource.file(localPath);
  }

  /// [examId]に対応する一意な教材metadataを取得します。
  Future<ExamSummary> _findSummary(String examId) async {
    final summaries = await _practiceRepository.getExams();
    final matches = summaries.where((item) => item.id == examId);
    if (matches.length != 1) {
      throw const QuestionImageUnavailableException('画像データの教材情報を確認できません。');
    }
    return matches.single;
  }
}
