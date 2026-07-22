import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/downloads/data/local_audio_resource_resolver.dart';
import 'package:nihongo_listening/features/downloads/domain/download_repository.dart';
import 'package:nihongo_listening/features/downloads/domain/download_state.dart';
import 'package:nihongo_listening/features/player/domain/audio_resource_resolver.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

import '../../../helpers/practice_test_fakes.dart';

/// AudioResourceResolverが配送方式ごとにAsset/Fileを選ぶことを確認します。
void main() {
  test('bundled教材はAsset、downloadRequired教材は検証済みFileを返す', () async {
    final exam = buildTestExam(questionCount: 1);
    final question = exam.questions.single;
    final bundled = LocalAudioResourceResolver(
      FakePracticeRepository(exam),
      _ResolverDownloadRepository('/local/q1.mp3'),
    );
    final required = LocalAudioResourceResolver(
      FakePracticeRepository(
        exam,
        audioDeliveryMode: AudioDeliveryMode.downloadRequired,
      ),
      _ResolverDownloadRepository('/local/q1.mp3'),
    );

    expect((await bundled.resolve(question)).isAsset, isTrue);
    final file = await required.resolve(question);
    expect(file.isFile, isTrue);
    expect(file.path, '/local/q1.mp3');
  });

  test('Local Fileが無効な場合はAssetへfallbackしない', () async {
    final exam = buildTestExam(questionCount: 1);
    final resolver = LocalAudioResourceResolver(
      FakePracticeRepository(
        exam,
        audioDeliveryMode: AudioDeliveryMode.downloadRequired,
      ),
      _ResolverDownloadRepository(null),
    );

    await expectLater(
      resolver.resolve(exam.questions.single),
      throwsA(isA<AudioResourceUnavailableException>()),
    );
  });
}

/// Resolverへ任意のLocal pathを返す最小Download Repository。
class _ResolverDownloadRepository implements DownloadRepository {
  /// [localPath]を解決結果として保持します。
  const _ResolverDownloadRepository(this.localPath);

  /// 問題音声のLocal File pathです。
  final String? localPath;

  @override
  Future<DownloadInspection> download(
    ExamSummary summary,
    ExamResource resource, {
    required void Function(double progress) onProgress,
  }) => throw UnimplementedError();

  @override
  Future<DownloadInspection> inspect(
    ExamSummary summary,
    ExamResource resource,
  ) async => const DownloadInspection(status: DownloadStatus.notDownloaded);

  @override
  Future<String?> resolveLocalAudioPath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async => localPath;

  @override
  Future<String?> resolveLocalImagePath(
    ExamSummary summary,
    ExamResource resource,
    Question question,
  ) async => null;
}
