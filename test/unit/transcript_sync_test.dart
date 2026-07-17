import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

void main() {
  const sentences = [
    TranscriptSentence(
      id: 's1',
      order: 0,
      textJa: '一文目',
      startMs: 0,
      endMs: 1000,
    ),
    TranscriptSentence(
      id: 's2',
      order: 1,
      textJa: '二文目',
      startMs: 1200,
      endMs: 2000,
    ),
  ];

  test('uses inclusive start and exclusive end boundaries', () {
    expect(findActiveSentence(sentences, Duration.zero)?.id, 's1');
    expect(
      findActiveSentence(sentences, const Duration(milliseconds: 999))?.id,
      's1',
    );
    expect(
      findActiveSentence(sentences, const Duration(milliseconds: 1000)),
      isNull,
    );
    expect(
      findActiveSentence(sentences, const Duration(milliseconds: 1200))?.id,
      's2',
    );
    expect(
      findActiveSentence(sentences, const Duration(milliseconds: 2000)),
      isNull,
    );
  });
}
