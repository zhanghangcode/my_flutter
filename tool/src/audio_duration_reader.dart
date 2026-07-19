import 'dart:io';
import 'dart:typed_data';

/// WAV または MP3 Asset のヘッダーを解析し、再生時間を milliseconds で返します。
///
/// 検証ツール専用の軽量な解析であり、対応外形式や破損ヘッダーは
/// [FormatException] として呼び出し元に通知します。
int readAudioDurationMs(File file) {
  final bytes = file.readAsBytesSync();
  final extension = file.path.split('.').last.toLowerCase();
  return switch (extension) {
    'wav' => _readWavDurationMs(bytes),
    'mp3' => _readMp3DurationMs(bytes),
    _ => throw FormatException('未対応の音声形式です: ${file.path}'),
  };
}

/// WAV の chunk 情報から byte rate と音声データ長を取り出し、再生時間を計算します。
int _readWavDurationMs(Uint8List bytes) {
  if (bytes.length < 44 ||
      _ascii(bytes, 0, 4) != 'RIFF' ||
      _ascii(bytes, 8, 4) != 'WAVE') {
    throw const FormatException('WAVヘッダーが不正です。');
  }
  final data = ByteData.sublistView(bytes);
  int? byteRate;
  int? audioDataSize;
  var offset = 12;
  while (offset + 8 <= bytes.length) {
    final chunkId = _ascii(bytes, offset, 4);
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    final chunkStart = offset + 8;
    if (chunkStart + chunkSize > bytes.length) break;
    if (chunkId == 'fmt ' && chunkSize >= 12) {
      byteRate = data.getUint32(chunkStart + 8, Endian.little);
    } else if (chunkId == 'data') {
      audioDataSize = chunkSize;
    }
    offset = chunkStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
  }
  if (byteRate == null || byteRate <= 0 || audioDataSize == null) {
    throw const FormatException('WAVのfmtまたはdata chunkが見つかりません。');
  }
  return (audioDataSize * 1000 / byteRate).round();
}

/// MP3 Layer III のフレームを走査し、サンプル数から再生時間を計算します。
///
/// ID3v2 タグを読み飛ばし、不正な候補は 1 byte ずつ進めて次のフレーム同期を探します。
int _readMp3DurationMs(Uint8List bytes) {
  var offset = _id3v2Size(bytes);
  var totalSamples = 0;
  var sampleRateForDuration = 0;
  var frameCount = 0;
  while (offset + 4 <= bytes.length) {
    final first = bytes[offset];
    final second = bytes[offset + 1];
    if (first != 0xff || (second & 0xe0) != 0xe0) {
      offset++;
      continue;
    }
    final versionBits = (second >> 3) & 0x03;
    final layerBits = (second >> 1) & 0x03;
    final bitrateIndex = (bytes[offset + 2] >> 4) & 0x0f;
    final sampleRateIndex = (bytes[offset + 2] >> 2) & 0x03;
    final padding = (bytes[offset + 2] >> 1) & 0x01;
    if (versionBits == 1 ||
        layerBits != 1 ||
        bitrateIndex == 0 ||
        bitrateIndex == 15 ||
        sampleRateIndex == 3) {
      offset++;
      continue;
    }

    final isMpeg1 = versionBits == 3;
    final bitrate = (isMpeg1 ? _mpeg1Layer3Bitrates : _mpeg2Layer3Bitrates)[
      bitrateIndex
    ];
    var sampleRate = _mpeg1SampleRates[sampleRateIndex];
    if (versionBits == 2) sampleRate ~/= 2;
    if (versionBits == 0) sampleRate ~/= 4;
    final frameLength =
        ((isMpeg1 ? 144000 : 72000) * bitrate / sampleRate).floor() +
        padding;
    if (frameLength <= 4 || offset + frameLength > bytes.length) {
      offset++;
      continue;
    }
    totalSamples += isMpeg1 ? 1152 : 576;
    sampleRateForDuration = sampleRate;
    frameCount++;
    offset += frameLength;
  }
  if (frameCount == 0 || sampleRateForDuration <= 0) {
    throw const FormatException('MP3 frameを解析できません。');
  }
  return (totalSamples * 1000 / sampleRateForDuration).round();
}

/// 先頭の ID3v2 タグ全体の長さを返し、タグがない場合は 0 を返します。
int _id3v2Size(Uint8List bytes) {
  if (bytes.length < 10 || _ascii(bytes, 0, 3) != 'ID3') return 0;
  final payloadSize =
      ((bytes[6] & 0x7f) << 21) |
      ((bytes[7] & 0x7f) << 14) |
      ((bytes[8] & 0x7f) << 7) |
      (bytes[9] & 0x7f);
  final hasFooter = (bytes[5] & 0x10) != 0;
  return 10 + payloadSize + (hasFooter ? 10 : 0);
}

/// [bytes] の指定範囲を ASCII 文字列として読み取ります。
String _ascii(Uint8List bytes, int start, int length) =>
    String.fromCharCodes(bytes.sublist(start, start + length));

/// MPEG-1 Layer III で使用するサンプルレートの対応表。
const _mpeg1SampleRates = [44100, 48000, 32000];

/// MPEG-1 Layer III の bitrate index に対応する kbps 値。
const _mpeg1Layer3Bitrates = [
  0,
  32,
  40,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  160,
  192,
  224,
  256,
  320,
  0,
];

/// MPEG-2/2.5 Layer III の bitrate index に対応する kbps 値。
const _mpeg2Layer3Bitrates = [
  0,
  8,
  16,
  24,
  32,
  40,
  48,
  56,
  64,
  80,
  96,
  112,
  128,
  144,
  160,
  0,
];
