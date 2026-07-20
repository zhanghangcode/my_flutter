import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

/// 問題モデルの JSON 変換と時間軸の扱いを検証する単体テスト群です。
void main() {
  test('音声配送方式とversionをJSONからparseする', () {
    final required = ExamSummary.fromJson({
      'id': 'download-exam',
      'titleJa': '試験',
      'audioQuality': '良い',
      'questionCount': 1,
      'resourcePath': 'assets/data/exam.json',
      'supportsTest': true,
      'audioDeliveryMode': 'downloadRequired',
      'audioResourceVersion': 3,
    });
    final bundledDefault = ExamSummary.fromJson({
      'id': 'bundled-exam',
      'titleJa': '試験',
      'audioQuality': '良い',
      'questionCount': 1,
      'resourcePath': 'assets/data/exam.json',
      'supportsTest': false,
    });

    expect(required.audioDeliveryMode, AudioDeliveryMode.downloadRequired);
    expect(required.audioResourceVersion, 3);
    expect(bundledDefault.audioDeliveryMode, AudioDeliveryMode.bundled);
    expect(bundledDefault.audioResourceVersion, 1);
  });

  test('文時間を整数millisecondsとしてparseする', () {
    final sentence = TranscriptSentence.fromJson({
      'id': 's001',
      'order': 0,
      'textJa': '本文',
      'startMs': 4200,
      'endMs': 5100,
    });

    expect(sentence.startMs, 4200);
    expect(sentence.endMs, 5100);
  });

  test('nullの文時間を保持する', () {
    final sentence = TranscriptSentence.fromJson({
      'id': 's001',
      'order': 0,
      'textJa': '本文',
      'startMs': null,
      'endMs': null,
    });

    expect(sentence.startMs, isNull);
    expect(sentence.endMs, isNull);
  });

  test('Stringや秒単位のdoubleをmillisecondsへ暗黙変換しない', () {
    Map<String, Object?> json(Object value) => {
      'id': 's001',
      'order': 0,
      'textJa': '本文',
      'startMs': value,
      'endMs': 5100,
    };

    expect(
      () => TranscriptSentence.fromJson(json('4200')),
      throwsFormatException,
    );
    expect(() => TranscriptSentence.fromJson(json(4.2)), throwsFormatException);
  });
}
