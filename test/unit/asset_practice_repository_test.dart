import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/practice/data/asset_practice_repository.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';
import 'package:nihongo_listening/features/practice/domain/practice_repository.dart';

void main() {
  // AssetBundle を利用できるよう、テスト用の Flutter Binding を初期化します。
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled demo and N2 practice catalog pass validation', () async {
    // Given: Bundle 内の実教材を読む Repository を用意します。
    final repository = AssetPracticeRepository();

    // When: catalog と、そこから参照される試験 JSON を読み込みます。
    final exams = await repository.getExams();

    // Then: 件数、本文、正解参照が想定どおりで、検証を通過したことを確認します。
    expect(exams, hasLength(2));
    final demo = await repository.getExam('2026_07_demo');
    expect(demo.questions, hasLength(3));
    expect(demo.questions.first.sentences, isNotEmpty);
    expect(
      demo.questions.first.options.any(
        (option) => option.id == demo.questions.first.correctOptionId,
      ),
      isTrue,
    );

    // Then: 練習専用教材は確定したquestionIdと音声pathで対応します。
    final summary = exams.singleWhere(
      (exam) => exam.id == 'n2_listening_problem1',
    );
    expect(summary.titleJa, 'N2聴解・問題1（3問）');
    expect(summary.year, isNull);
    expect(summary.month, isNull);
    expect(summary.supportsTest, isFalse);
    final practice = await repository.getExam(summary.id);
    expect(practice.schemaVersion, 2);
    expect(practice.questions, hasLength(3));
    expect(
      {
        for (final question in practice.questions)
          question.id: question.audioAssetPath,
      },
      {
        'n2_listening_problem1_q01': 'assets/audio/問題1_第01問.mp3',
        'n2_listening_problem1_q02': 'assets/audio/問題1_第02問.mp3',
        'n2_listening_problem1_q03': 'assets/audio/問題1_第03問.mp3',
      },
    );
    for (final question in practice.questions) {
      expect(question.options, isEmpty);
      expect(question.correctOptionId, isNull);
      expect(question.explanation, isNull);
      expect(question.isGradable, isFalse);
      expect(question.hasCompleteTimeline, isFalse);
      expect(question.sentences, isNotEmpty);
    }
  });

  test('rejects a partial sentence timeline', () async {
    final question = _question();
    (question['sentences'] as List<Map<String, dynamic>>).single['startMs'] = 0;
    final repository = AssetPracticeRepository(
      bundle: _bundleFor(question: question),
    );

    await expectLater(
      repository.getExam('exam'),
      throwsA(
        isA<ContentValidationException>().having(
          (error) => error.toString(),
          'message',
          contains('時間情報が不正です'),
        ),
      ),
    );

    final mixedTimeline = _question();
    (mixedTimeline['sentences'] as List<Map<String, dynamic>>).insert(0, {
      'id': 'q1_s0',
      'order': 0,
      'textJa': '時間あり本文',
      'startMs': 0,
      'endMs': 1000,
    });
    (mixedTimeline['sentences'] as List<Map<String, dynamic>>)[1]['order'] = 1;
    final mixedRepository = AssetPracticeRepository(
      bundle: _bundleFor(question: mixedTimeline),
    );
    await expectLater(
      mixedRepository.getExam('exam'),
      throwsA(
        isA<ContentValidationException>().having(
          (error) => error.toString(),
          'message',
          contains('時間軸が部分的に設定されています'),
        ),
      ),
    );
  });

  test('rejects invalid correct option and missing audio assets', () async {
    final invalidAnswer = _question()..['correctOptionId'] = 'missing-option';
    final answerRepository = AssetPracticeRepository(
      bundle: _bundleFor(question: invalidAnswer),
    );
    await expectLater(
      answerRepository.getExam('exam'),
      throwsA(
        isA<ContentValidationException>().having(
          (error) => error.toString(),
          'message',
          contains('正解の選択肢がありません'),
        ),
      ),
    );

    final audioRepository = AssetPracticeRepository(
      bundle: _bundleFor(question: _question(), includeAudio: false),
    );
    await expectLater(
      audioRepository.getExam('exam'),
      throwsA(
        isA<ContentValidationException>().having(
          (error) => error.toString(),
          'message',
          allOf(contains('q1'), contains('assets/audio/q1.mp3')),
        ),
      ),
    );
  });

  test(
    'rejects zero-byte audio and catalog question count mismatches',
    () async {
      final zeroAudioRepository = AssetPracticeRepository(
        bundle: _bundleFor(question: _question(), audioBytes: const []),
      );
      await expectLater(
        zeroAudioRepository.getExam('exam'),
        throwsA(isA<ContentValidationException>()),
      );

      final countRepository = AssetPracticeRepository(
        bundle: _bundleFor(question: _question(), questionCount: 2),
      );
      await expectLater(
        countRepository.getExam('exam'),
        throwsA(
          isA<ContentValidationException>().having(
            (error) => error.toString(),
            'message',
            contains('問題数が教材一覧と一致しません'),
          ),
        ),
      );
    },
  );

  test('detects duplicate question ids across exams', () async {
    final first = _question();
    final second = _question()..['examId'] = 'exam-2';
    final assets = <String, List<int>>{
      'assets/data/catalog.json': utf8.encode(
        jsonEncode({
          'schemaVersion': 2,
          'exams': [
            _summary(id: 'exam', path: 'assets/data/exams/exam.json'),
            _summary(id: 'exam-2', path: 'assets/data/exams/exam-2.json'),
          ],
        }),
      ),
      'assets/data/exams/exam.json': utf8.encode(
        jsonEncode(_resource(id: 'exam', question: first)),
      ),
      'assets/data/exams/exam-2.json': utf8.encode(
        jsonEncode(_resource(id: 'exam-2', question: second)),
      ),
      'assets/audio/q1.mp3': const [1],
    };
    final repository = AssetPracticeRepository(
      bundle: _MemoryAssetBundle(assets),
    );

    await expectLater(
      repository.getQuestion('q1'),
      throwsA(
        isA<ContentValidationException>().having(
          (error) => error.toString(),
          'message',
          contains('試験間で重複'),
        ),
      ),
    );
  });
}

Map<String, dynamic> _summary({
  String id = 'exam',
  String path = 'assets/data/exams/exam.json',
  int questionCount = 1,
}) => {
  'id': id,
  'year': null,
  'month': null,
  'titleJa': '試験',
  'audioQuality': '不明',
  'questionCount': questionCount,
  'resourcePath': path,
  'supportsTest': false,
};

Map<String, dynamic> _resource({
  required String id,
  required Map<String, dynamic> question,
}) => {
  'schemaVersion': 2,
  'id': id,
  'titleJa': '試験',
  'questions': [question],
};

Map<String, dynamic> _question() => {
  'id': 'q1',
  'examId': 'exam',
  'section': 1,
  'number': 1,
  'type': '課題理解',
  'promptJa': '問題文',
  'options': <Map<String, dynamic>>[],
  'correctOptionId': null,
  'audioAssetPath': 'assets/audio/q1.mp3',
  'sentences': <Map<String, dynamic>>[
    {'id': 'q1_s1', 'order': 0, 'textJa': '本文'},
  ],
  'explanation': null,
};

AssetBundle _bundleFor({
  required Map<String, dynamic> question,
  bool includeAudio = true,
  List<int> audioBytes = const [1],
  int questionCount = 1,
}) {
  final assets = <String, List<int>>{
    'assets/data/catalog.json': utf8.encode(
      jsonEncode({
        'schemaVersion': 2,
        'exams': [_summary(questionCount: questionCount)],
      }),
    ),
    'assets/data/exams/exam.json': utf8.encode(
      jsonEncode(_resource(id: 'exam', question: question)),
    ),
    if (includeAudio) 'assets/audio/q1.mp3': audioBytes,
  };
  return _MemoryAssetBundle(assets);
}

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.assets);

  final Map<String, List<int>> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw StateError('Asset not found: $key');
    return Uint8List.fromList(bytes).buffer.asByteData();
  }
}
