import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
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
    expect(progress.first, 0);
    expect(progress.last, 1);
    for (var index = 1; index < progress.length; index++) {
      expect(progress[index], greaterThanOrEqualTo(progress[index - 1]));
    }
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

  test('audio-vbr配下・日本語ファイル名・__MACOSX混入のZIPを29問すべて保存する', () async {
    final practiceRepository = AssetPracticeRepository();
    final summary = (await practiceRepository.getExams()).singleWhere(
      (exam) => exam.id == 'n2_listening',
    );
    final resource = await practiceRepository.getExam(summary.id);
    final zipSource = _ZipDownloadSource((archive) {
      for (final question in resource.questions) {
        final basename = p.basename(question.audioAssetPath);
        archive.addFile(
          ArchiveFile.bytes(
            'audio-vbr/$basename',
            Uint8List.fromList(utf8.encode(question.id)),
          ),
        );
      }
      archive.addFile(
        ArchiveFile.bytes('__MACOSX/audio-vbr/._junk.mp3', Uint8List(4)),
      );
      archive.addFile(
        ArchiveFile.bytes('__MACOSX/._audio-vbr', Uint8List.fromList([0, 0])),
      );
    });
    final zipRepository = LocalDownloadRepository(
      zipSource,
      database,
      resolveBaseDirectory: () async => temporaryDirectory,
    );

    final inspection = await zipRepository.download(
      summary,
      resource,
      onProgress: (_) {},
    );

    expect(inspection.status, DownloadStatus.downloaded);
    expect(inspection.localAudioPaths, hasLength(29));
    for (final question in resource.questions) {
      final path = inspection.localAudioPaths[question.id]!;
      expect(await File(path).readAsString(), question.id);
    }
  });

  test('ZIP内の重複basenameは保存全体を失敗させる', () async {
    final zipSource = _ZipDownloadSource((archive) {
      archive.addFile(
        ArchiveFile.bytes('assets/audio/q1.mp3', Uint8List.fromList([1])),
      );
      archive.addFile(
        ArchiveFile.bytes('audio-vbr/q1.mp3', Uint8List.fromList([2])),
      );
      archive.addFile(
        ArchiveFile.bytes('assets/audio/q2.m4a', Uint8List.fromList([3])),
      );
    });
    final zipRepository = LocalDownloadRepository(
      zipSource,
      database,
      resolveBaseDirectory: () async => temporaryDirectory,
    );

    await expectLater(
      zipRepository.download(_summary(), _resource(), onProgress: (_) {}),
      throwsA(anything),
    );
    final inspection = await zipRepository.inspect(_summary(), _resource());
    expect(inspection.status, DownloadStatus.failed);
  });

  test(
    'imageAssetPathを持つ問題は画像も一緒にダウンロードしresolveLocalImagePathで解決できる',
    () async {
      final resource = _resourceWithImage();
      final zipSource = _ZipDownloadSource((archive) {
        archive.addFile(
          ArchiveFile.bytes('assets/audio/q1.mp3', Uint8List.fromList([1])),
        );
        archive.addFile(
          ArchiveFile.bytes('assets/audio/q2.m4a', Uint8List.fromList([2])),
        );
        archive.addFile(
          ArchiveFile.bytes('assets/images/q1.jpg', Uint8List.fromList([3, 4])),
        );
      });
      final zipRepository = LocalDownloadRepository(
        zipSource,
        database,
        resolveBaseDirectory: () async => temporaryDirectory,
      );

      final inspection = await zipRepository.download(
        _summary(),
        resource,
        onProgress: (_) {},
      );

      expect(inspection.status, DownloadStatus.downloaded);
      expect(inspection.localAudioPaths, hasLength(2));
      // q2はimageAssetPathを持たないため、localImagePathsにはq1だけが含まれます。
      expect(inspection.localImagePaths.keys, {'q1'});
      expect(
        inspection.localImagePaths['q1'],
        p.join(
          temporaryDirectory.path,
          'downloads',
          'exams',
          'exam',
          'images',
          'q1.jpg',
        ),
      );

      final q1Path = await zipRepository.resolveLocalImagePath(
        _summary(),
        resource,
        resource.questions.first,
      );
      expect(q1Path, inspection.localImagePaths['q1']);
      final q2Path = await zipRepository.resolveLocalImagePath(
        _summary(),
        resource,
        resource.questions.last,
      );
      expect(q2Path, isNull);
    },
  );

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

/// pathごとの固定bytesからZIPを生成するDownload Source。
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
  Future<void> downloadArchive(
    ExamSummary summary,
    ExamResource resource,
    File destination, {
    required void Function(double progress) onProgress,
  }) async {
    final archive = Archive();
    onProgress(0);
    for (var index = 0; index < resource.questions.length; index++) {
      final question = resource.questions[index];
      fetchedQuestionIds.add(question.id);
      final error = errors[question.audioAssetPath];
      if (error != null) throw error;
      final content = bytes[question.audioAssetPath] ?? Uint8List(0);
      archive.addFile(ArchiveFile.bytes(question.audioAssetPath, content));
      onProgress((index + 1) / resource.questions.length);
    }
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(
      ZipEncoder().encodeBytes(archive),
      flush: true,
    );
  }
}

/// 任意のZIP内容を[build]で組み立てて返すDownload Source。
class _ZipDownloadSource implements DownloadSource {
  /// [build]でarchiveへ任意のentryを追加するSourceを生成します。
  _ZipDownloadSource(this.build);

  /// ZIPへentryを追加するcallbackです。
  final void Function(Archive archive) build;

  @override
  Future<void> downloadArchive(
    ExamSummary summary,
    ExamResource resource,
    File destination, {
    required void Function(double progress) onProgress,
  }) async {
    onProgress(0);
    final archive = Archive();
    build(archive);
    await destination.parent.create(recursive: true);
    await destination.writeAsBytes(
      ZipEncoder().encodeBytes(archive),
      flush: true,
    );
    onProgress(1);
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

/// q1だけがimageAssetPathを持つ試験を生成します。
ExamResource _resourceWithImage() => const ExamResource(
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
      imageAssetPath: 'assets/images/q1.jpg',
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
