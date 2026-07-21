import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/downloads/data/r2_zip_download_source.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

/// 教材metadataに設定されたR2 ZIP URLの検証を確認します。
void main() {
  test('教材metadataのaudioPackageUrlをそのまま利用する', () {
    final source = R2ZipDownloadSource();

    expect(
      source.archiveUriFor(_summary()),
      Uri.parse('https://download.appsaudio.com/202407_audio.zip'),
    );
  });

  test('HTTPS以外のURLを拒否する', () {
    final source = R2ZipDownloadSource();

    expect(
      () => source.archiveUriFor(
        _summary(
          audioPackageUrl: 'http://download.appsaudio.com/202407_audio.zip',
        ),
      ),
      throwsFormatException,
    );
  });

  test('未設定のURLを拒否する', () {
    final source = R2ZipDownloadSource();

    expect(
      () => source.archiveUriFor(_summary(audioPackageUrl: null)),
      throwsFormatException,
    );
  });

  test('不正な形式のURLを拒否する', () {
    final source = R2ZipDownloadSource();

    expect(
      () => source.archiveUriFor(_summary(audioPackageUrl: 'not a url')),
      throwsFormatException,
    );
  });
}

ExamSummary _summary({
  String? audioPackageUrl = 'https://download.appsaudio.com/202407_audio.zip',
}) => ExamSummary(
  id: 'n2_listening',
  year: 2024,
  month: 7,
  titleJa: '2024年7月・JLPT N2聴解',
  audioQuality: '不明',
  questionCount: 29,
  resourcePath: 'assets/data/exams/n2_listening_problem123.json',
  supportsTest: false,
  audioDeliveryMode: AudioDeliveryMode.downloadRequired,
  audioResourceVersion: 1,
  audioPackageUrl: audioPackageUrl,
);
