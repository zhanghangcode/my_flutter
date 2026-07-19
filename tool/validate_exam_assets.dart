import 'dart:convert';
import 'dart:io';

import 'src/audio_duration_reader.dart';

/// 検証対象となる教材カタログの Asset 相対 path。
const _catalogPath = 'assets/data/catalog.json';

/// 今回導入した問題と音声 Asset の確定対応表。
const _expectedAudioByQuestionId = <String, String>{
  'n2_listening_problem1_q01': 'assets/audio/問題1_第01問.mp3',
  'n2_listening_problem1_q02': 'assets/audio/問題1_第02問.mp3',
  'n2_listening_problem1_q03': 'assets/audio/問題1_第03問.mp3',
};

/// Bundle へ登録する試験 JSON と音声 Asset の参照整合性を検証します。
///
/// カタログからすべての試験を走査し、ID、問題数、選択肢、時間軸、音声ファイルを
/// 検証します。エラーをまとめて標準エラー出力へ出し、終了コードを 1 に設定します。
Future<void> main() async {
  final errors = <String>[];
  final globalQuestionIds = <String>{};
  final globalSentenceIds = <String>{};
  final importedQuestionIds = <String>{};

  final catalogFile = File(_catalogPath);
  if (!catalogFile.existsSync()) {
    stderr.writeln('教材一覧が見つかりません: $_catalogPath');
    exitCode = 1;
    return;
  }

  Map<String, dynamic> catalog;
  try {
    catalog =
        jsonDecode(await catalogFile.readAsString()) as Map<String, dynamic>;
  } catch (error) {
    stderr.writeln('教材一覧JSONを解析できません: $_catalogPath\n$error');
    exitCode = 1;
    return;
  }

  if (catalog['schemaVersion'] != 2) {
    errors.add('schemaVersionが2ではありません: $_catalogPath');
  }
  final exams = catalog['exams'];
  if (exams is! List) {
    errors.add('examsが配列ではありません: $_catalogPath');
  } else {
    final examIds = <String>{};
    for (final rawExam in exams) {
      if (rawExam is! Map<String, dynamic>) {
        errors.add('試験情報がObjectではありません: $_catalogPath');
        continue;
      }
      final examId = rawExam['id'];
      final resourcePath = rawExam['resourcePath'];
      final questionCount = rawExam['questionCount'];
      final supportsTest = rawExam['supportsTest'];
      if (examId is! String || examId.isEmpty) {
        errors.add('examIdが空または不正です: $_catalogPath');
        continue;
      }
      if (!examIds.add(examId)) {
        errors.add('examIdが重複しています: $examId ($_catalogPath)');
      }
      if (resourcePath is! String || resourcePath.isEmpty) {
        errors.add('resourcePathが空または不正です: $examId');
        continue;
      }
      if (questionCount is! int || questionCount < 0) {
        errors.add('questionCountが不正です: $examId ($resourcePath)');
      }
      if (supportsTest is! bool) {
        errors.add('supportsTestがboolではありません: $examId ($resourcePath)');
      }
      await _validateExam(
        examId: examId,
        resourcePath: resourcePath,
        expectedQuestionCount: questionCount is int ? questionCount : -1,
        supportsTest: supportsTest == true,
        globalQuestionIds: globalQuestionIds,
        globalSentenceIds: globalSentenceIds,
        importedQuestionIds: importedQuestionIds,
        errors: errors,
      );
    }
  }

  for (final questionId in _expectedAudioByQuestionId.keys) {
    if (!importedQuestionIds.contains(questionId)) {
      errors.add('導入対象のquestionIdがありません: $questionId');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('試験Asset検証で${errors.length}件のエラーを検出しました。');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    '試験Asset検証に成功しました: '
    '${globalQuestionIds.length}問 / ${globalSentenceIds.length}文',
  );
}

/// 1 試験分の JSON を読み込み、カタログとの整合性と各問題を検証します。
Future<void> _validateExam({
  required String examId,
  required String resourcePath,
  required int expectedQuestionCount,
  required bool supportsTest,
  required Set<String> globalQuestionIds,
  required Set<String> globalSentenceIds,
  required Set<String> importedQuestionIds,
  required List<String> errors,
}) async {
  final resourceFile = File(resourcePath);
  if (!resourceFile.existsSync()) {
    errors.add('試験JSONが見つかりません: $examId ($resourcePath)');
    return;
  }
  Map<String, dynamic> resource;
  try {
    resource =
        jsonDecode(await resourceFile.readAsString()) as Map<String, dynamic>;
  } catch (error) {
    errors.add('試験JSONを解析できません: $examId ($resourcePath) $error');
    return;
  }
  if (resource['schemaVersion'] != 2) {
    errors.add('schemaVersionが2ではありません: $examId ($resourcePath)');
  }
  if (resource['id'] != examId) {
    errors.add('catalogと試験JSONのexamIdが一致しません: $examId ($resourcePath)');
  }
  final questions = resource['questions'];
  if (questions is! List) {
    errors.add('questionsが配列ではありません: $examId ($resourcePath)');
    return;
  }
  if (questions.length != expectedQuestionCount) {
    errors.add(
      'questionCountが一致しません: $examId '
      'catalog=$expectedQuestionCount json=${questions.length} ($resourcePath)',
    );
  }
  for (final rawQuestion in questions) {
    if (rawQuestion is! Map<String, dynamic>) {
      errors.add('問題がObjectではありません: $examId ($resourcePath)');
      continue;
    }
    _validateQuestion(
      examId: examId,
      resourcePath: resourcePath,
      question: rawQuestion,
      supportsTest: supportsTest,
      globalQuestionIds: globalQuestionIds,
      globalSentenceIds: globalSentenceIds,
      importedQuestionIds: importedQuestionIds,
      errors: errors,
    );
  }
}

/// 問題 ID、音声、選択肢、正解、Transcript と時間軸の整合性を検証します。
///
/// 検出した問題は [errors] へ追加し、他問題のエラーも続けて収集できるよう例外では
/// 中断しません。
void _validateQuestion({
  required String examId,
  required String resourcePath,
  required Map<String, dynamic> question,
  required bool supportsTest,
  required Set<String> globalQuestionIds,
  required Set<String> globalSentenceIds,
  required Set<String> importedQuestionIds,
  required List<String> errors,
}) {
  final questionId = question['id'];
  if (questionId is! String || questionId.isEmpty) {
    errors.add('questionIdが空または不正です: $examId ($resourcePath)');
    return;
  }
  if (!globalQuestionIds.add(questionId)) {
    errors.add('questionIdが重複しています: $questionId ($resourcePath)');
  }
  if (question['examId'] != examId) {
    errors.add('question.examIdが一致しません: $questionId ($resourcePath)');
  }
  if (question['section'] is! int ||
      (question['section'] as int) <= 0 ||
      question['number'] is! int ||
      (question['number'] as int) <= 0) {
    errors.add('sectionまたはnumberが不正です: $questionId ($resourcePath)');
  }

  final audioAssetPath = question['audioAssetPath'];
  int? audioDurationMs;
  if (audioAssetPath is! String || audioAssetPath.isEmpty) {
    errors.add('audioAssetPathが空または不正です: $questionId ($resourcePath)');
  } else {
    final audioFile = File(audioAssetPath);
    if (!audioFile.existsSync() || audioFile.lengthSync() == 0) {
      errors.add('音声Assetが存在しないか空です: $questionId ($audioAssetPath)');
    } else {
      try {
        audioDurationMs = readAudioDurationMs(audioFile);
      } catch (error) {
        errors.add(
          '音声Durationを取得できません: examId=$examId, '
          'questionId=$questionId, audioAsset=$audioAssetPath, error=$error',
        );
      }
    }
    final expectedAudio = _expectedAudioByQuestionId[questionId];
    if (expectedAudio != null) {
      importedQuestionIds.add(questionId);
      if (audioAssetPath != expectedAudio) {
        errors.add(
          '確定済み音声対応と一致しません: $questionId '
          'expected=$expectedAudio actual=$audioAssetPath',
        );
      }
    }
  }

  final options = question['options'];
  final optionIds = <String>{};
  if (options is! List) {
    errors.add('optionsが配列ではありません: $questionId ($resourcePath)');
  } else {
    for (final option in options) {
      if (option is! Map<String, dynamic> ||
          option['id'] is! String ||
          (option['id'] as String).isEmpty ||
          !optionIds.add(option['id'] as String)) {
        errors.add('option idが不正または重複しています: $questionId ($resourcePath)');
      }
    }
  }
  final correctOptionId = question['correctOptionId'];
  if (correctOptionId != null &&
      (correctOptionId is! String || !optionIds.contains(correctOptionId))) {
    errors.add('correctOptionIdがoptions内にありません: $questionId ($resourcePath)');
  }
  if (supportsTest &&
      (options is! List || options.length < 2 || correctOptionId == null)) {
    errors.add('テスト対象の選択肢または正解が不足しています: $questionId ($resourcePath)');
  }

  final sentences = question['sentences'];
  if (sentences is! List || sentences.isEmpty) {
    errors.add('Transcriptが空または不正です: $questionId ($resourcePath)');
    return;
  }
  var previousEnd = -1;
  var hasTimedSentence = false;
  var hasUntimedSentence = false;
  String? firstTimedDetails;
  String? firstUntimedDetails;
  final startValues = <int>{};
  for (var index = 0; index < sentences.length; index++) {
    final sentence = sentences[index];
    if (sentence is! Map<String, dynamic>) {
      errors.add('Transcript文がObjectではありません: $questionId ($resourcePath)');
      continue;
    }
    final sentenceId = sentence['id'];
    if (sentenceId is! String ||
        sentenceId.isEmpty ||
        !globalSentenceIds.add(sentenceId)) {
      errors.add('文IDが不正または重複しています: $questionId ($resourcePath)');
    }
    if (sentence['order'] != index) {
      errors.add('文のorderが不正です: $questionId / $sentenceId ($resourcePath)');
    }
    final startMs = sentence['startMs'];
    final endMs = sentence['endMs'];
    final timelineDetails = _timelineDetails(
      examId: examId,
      questionId: questionId,
      sentenceId: sentenceId,
      audioAssetPath: audioAssetPath,
      startMs: startMs,
      endMs: endMs,
      audioDurationMs: audioDurationMs,
    );
    if ((startMs == null) != (endMs == null)) {
      errors.add('startMs/endMsの片方だけが存在します: $timelineDetails');
      continue;
    }
    if (startMs == null) {
      hasUntimedSentence = true;
      firstUntimedDetails ??= timelineDetails;
    } else if (endMs != null) {
      hasTimedSentence = true;
      firstTimedDetails ??= timelineDetails;
      if (startMs is! int || endMs is! int) {
        errors.add('文時間が整数millisecondsではありません: $timelineDetails');
        continue;
      }
      if (!startValues.add(startMs)) {
        errors.add('startMsが重複しています: $timelineDetails');
      }
      if (startMs < 0 || endMs <= startMs || startMs < previousEnd) {
        errors.add('時間軸の順序または範囲が不正です: $timelineDetails');
      }
      if (audioDurationMs != null &&
          (startMs > audioDurationMs || endMs > audioDurationMs)) {
        errors.add(
          '文時間が問題別音声Durationを超えています。'
          '全体音声の絶対時間が残っていないか確認してください: $timelineDetails',
        );
      }
      previousEnd = endMs;
    }
  }
  if (hasTimedSentence && hasUntimedSentence) {
    errors.add(
      '時間軸が部分的に設定されています: '
      'timed=[$firstTimedDetails], untimed=[$firstUntimedDetails]',
    );
  }
}

/// 時間軸エラーに必要な試験・問題・音声の識別情報を整形します。
String _timelineDetails({
  required String examId,
  required String questionId,
  required Object? sentenceId,
  required Object? audioAssetPath,
  required Object? startMs,
  required Object? endMs,
  required int? audioDurationMs,
}) =>
    'examId=$examId, questionId=$questionId, sentenceId=$sentenceId, '
    'audioAsset=$audioAssetPath, startMs=$startMs, endMs=$endMs, '
    'audioDurationMs=$audioDurationMs';
