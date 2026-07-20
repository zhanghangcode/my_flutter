import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/database/app_database.dart';
import 'package:nihongo_listening/features/downloads/data/local_download_repository.dart';
import 'package:nihongo_listening/features/downloads/data/mock_download_source.dart';
import 'package:nihongo_listening/features/downloads/domain/download_source.dart';
import 'package:nihongo_listening/features/downloads/domain/download_state.dart';
import 'package:nihongo_listening/features/practice/data/asset_practice_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:path/path.dart' as p;

/// LocalDownloadRepositoryの原子的保存とManifest検証を確認します。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryDirectory;
  late AppDatabase database;
  late _MemoryDownloadSource source;
  late LocalDownloadRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'nihongo-download-test-',
    );
    database = AppDatabase.forTesting(NativeDatabase.memory());
    source = _MemoryDownloadSource({
      'assets/audio/q1.mp3': Uint8List.fromList([1, 2, 3]),
      'assets/audio/q2.m4a': Uint8List.fromList([4, 5]),
    });
    repository = LocalDownloadRepository(
      source,
      database,
      resolveBaseDirectory: () async => temporaryDirectory,
    );
  });

  tearDown(() async {
    await database.close();
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('questionIdのファイル名へpart経由で保存し、再起動相当の検査で復元する', () async {
    final progress = <double>[];

    final downloaded = await repository.download(
      _summary(),
      _resource(),
      onProgress: progress.add,
    );

    expect(downloaded.status, DownloadStatus.downloaded);
    expect(progress, [0, 0.5, 1]);
    expect(downloaded.localAudioPaths.keys, {'q1', 'q2'});
    expect(
      downloaded.localAudioPaths['q1'],
      p.join(
        temporaryDirectory.path,
        'downloads',
        'exams',
        'exam',
        'audio',
        'q1.mp3',
      ),
    );
    expect(
      await Directory(
        p.join(temporaryDirectory.path, 'downloads', 'exams', 'exam', 'audio'),
      ).list().where((entity) => entity.path.endsWith('.part')).isEmpty,
      isTrue,
    );

    final restored = await repository.inspect(_summary(), _resource());
    expect(restored.isDownloaded, isTrue);
    expect(source.fetchedQuestionIds, ['q1', 'q2']);
  });

  test('実Catalogの2026年7月音声をMock SourceからLocal Fileへ複製する', () async {
    final practiceRepository = AssetPracticeRepository();
    final summary = (await practiceRepository.getExams()).singleWhere(
      (exam) => exam.id == '2026_07_demo',
    );
    final resource = await practiceRepository.getExam(summary.id);
    final mockRepository = LocalDownloadRepository(
      MockDownloadSource(),
      database,
      resolveBaseDirectory: () async => temporaryDirectory,
    );

    final inspection = await mockRepository.download(
      summary,
      resource,
      onProgress: (_) {},
    );

    expect(inspection.localAudioPaths, hasLength(resource.questions.length));
    final firstQuestion = resource.questions.first;
    final sourceBytes = await rootBundle.load(firstQuestion.audioAssetPath);
    expect(
      await File(inspection.localAudioPaths[firstQuestion.id]!).length(),
      sourceBytes.lengthInBytes,
    );
  });

  test('実ファイル欠落、0-byte、part残留、version違いをdownloadedとして扱わない', () async {
    final downloaded = await repository.download(
      _summary(),
      _resource(),
      onProgress: (_) {},
    );
    final q1 = File(downloaded.localAudioPaths['q1']!);

    await q1.writeAsBytes(const [], flush: true);
    expect(
      (await repository.inspect(_summary(), _resource())).isDownloaded,
      isFalse,
    );
    await q1.writeAsBytes(const [1], flush: true);
    await File('${q1.path}.part').writeAsBytes(const [9]);
    expect(
      (await repository.inspect(_summary(), _resource())).isDownloaded,
      isFalse,
    );
    await File('${q1.path}.part').delete();
    final versionMismatch = await repository.inspect(
      _summary().copyWith(audioResourceVersion: 2),
      _resource(),
    );
    expect(versionMismatch.isDownloaded, isFalse);
  });

  test('途中取得が失敗した場合は試験Directoryを削除してfailed Manifestを保存する', () async {
    source.errors['assets/audio/q2.m4a'] = StateError('source failure');

    await expectLater(
      repository.download(_summary(), _resource(), onProgress: (_) {}),
      throwsA(anything),
    );

    final examDirectory = Directory(
      p.join(temporaryDirectory.path, 'downloads', 'exams', 'exam'),
    );
    expect(await examDirectory.exists(), isFalse);
    final inspection = await repository.inspect(_summary(), _resource());
    expect(inspection.status, DownloadStatus.failed);
  });
}

/// pathごとに固定bytesまたはエラーを返すDownload Source。
class _MemoryDownloadSource implements DownloadSource {
  /// [bytes]を取得結果として保持します。
  _MemoryDownloadSource(this.bytes);

  /// sourcePathごとの取得bytesです。
  final Map<String, Uint8List> bytes;

  /// sourcePathごとに送出する任意エラーです。
  final Map<String, Object> errors = {};

  /// 取得順を確認するquestionId一覧です。
  final List<String> fetchedQuestionIds = [];

  @override
  Future<Uint8List> fetch(DownloadItem item) async {
    fetchedQuestionIds.add(item.questionId);
    final error = errors[item.sourcePath];
    if (error != null) throw error;
    return bytes[item.sourcePath] ?? Uint8List(0);
  }
}

/// Download必須の試験metadataを生成します。
ExamSummary _summary() => const ExamSummary(
  id: 'exam',
  year: 2026,
  month: 7,
  titleJa: '2026年7月',
  audioQuality: '良い',
  questionCount: 2,
  resourcePath: 'assets/data/exams/exam.json',
  supportsTest: true,
  audioDeliveryMode: AudioDeliveryMode.downloadRequired,
  audioResourceVersion: 1,
);

/// 2つの問題別音声を参照する試験を生成します。
ExamResource _resource() => const ExamResource(
  schemaVersion: 2,
  id: 'exam',
  titleJa: '2026年7月',
  questions: [
    Question(
      id: 'q1',
      examId: 'exam',
      section: 1,
      number: 1,
      type: 'demo',
      promptJa: '問題1',
      options: [],
      audioAssetPath: 'assets/audio/q1.mp3',
      sentences: [],
    ),
    Question(
      id: 'q2',
      examId: 'exam',
      section: 1,
      number: 2,
      type: 'demo',
      promptJa: '問題2',
      options: [],
      audioAssetPath: 'assets/audio/q2.m4a',
      sentences: [],
    ),
  ],
);
