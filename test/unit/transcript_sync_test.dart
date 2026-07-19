import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_listening/features/player/application/audio_player_controller.dart';
import 'package:nihongo_listening/features/practice/domain/practice_models.dart';

/// 再生位置と Transcript 文の対応境界を検証する単体テスト群です。
void main() {
  // Given: 1 秒から 1.2 秒の間に空白を持つ、時間順の本文を用意します。
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
    // When / Then: 開始時刻は対象文に含み、終了時刻と文間の空白は含まないことを
    // 境界値ごとに確認します。
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

  test('returns no active sentence when any timeline value is missing', () {
    // Given: 本文は存在するものの、文時間を持たない教材を用意します。
    const untimed = [
      TranscriptSentence(id: 'untimed', order: 0, textJa: '時間情報のない本文'),
    ];

    // When / Then: 時間を推測せず、同期対象なしとして扱います。
    expect(findActiveSentence(untimed, Duration.zero), isNull);
  });

  test('question capabilities reject overlapping timelines', () {
    final question = Question(
      id: 'q1',
      examId: 'exam',
      section: 1,
      number: 1,
      type: '課題理解',
      promptJa: '問題文',
      options: const [],
      audioAssetPath: 'assets/audio/q1.mp3',
      sentences: const [
        TranscriptSentence(
          id: 's1',
          order: 0,
          textJa: '1文目',
          startMs: 0,
          endMs: 1000,
        ),
        TranscriptSentence(
          id: 's2',
          order: 1,
          textJa: '2文目',
          startMs: 900,
          endMs: 1500,
        ),
      ],
    );

    // 時刻がすべて存在しても、重複する時間軸は同期可能と判定しません。
    expect(question.hasCompleteTimeline, isFalse);
  });
}
