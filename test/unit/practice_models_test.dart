import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

void main() {
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
