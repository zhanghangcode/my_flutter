import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice_models.freezed.dart';
part 'practice_models.g.dart';

int? _nullableMillisecondsFromJson(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException('文時間は整数millisecondsで指定してください: $value');
}

/// 練習詳細で切り替えられる 4 種類の表示モード。
enum ContentMode { transcript, question, combined, explanation }

/// 教材一覧 JSON のルートモデル。
///
/// schemaVersion により、アプリが対応できる教材形式かを読み込み時に判定します。
@freezed
abstract class ExamCatalog with _$ExamCatalog {
  const factory ExamCatalog({
    required int schemaVersion,
    required List<ExamSummary> exams,
  }) = _ExamCatalog;

  factory ExamCatalog.fromJson(Map<String, dynamic> json) =>
      _$ExamCatalogFromJson(json);
}

/// 一覧画面に必要な試験メタデータと、詳細 JSON の参照先を表します。
@freezed
abstract class ExamSummary with _$ExamSummary {
  const factory ExamSummary({
    required String id,
    int? year,
    int? month,
    required String titleJa,
    required String audioQuality,
    required int questionCount,
    required String resourcePath,
    required bool supportsTest,
  }) = _ExamSummary;

  factory ExamSummary.fromJson(Map<String, dynamic> json) =>
      _$ExamSummaryFromJson(json);
}

/// 1 回分の試験情報と、その試験に含まれる問題一覧を表します。
@freezed
abstract class ExamResource with _$ExamResource {
  const factory ExamResource({
    required int schemaVersion,
    required String id,
    required String titleJa,
    required List<Question> questions,
  }) = _ExamResource;

  factory ExamResource.fromJson(Map<String, dynamic> json) =>
      _$ExamResourceFromJson(json);
}

/// 音声、時間付き本文、選択肢、正解、解説をまとめた 1 問分のモデル。
@freezed
abstract class Question with _$Question {
  const factory Question({
    required String id,
    required String examId,
    required int section,
    required int number,
    required String type,
    required String promptJa,
    required List<AnswerOption> options,
    String? correctOptionId,
    required String audioAssetPath,
    required List<TranscriptSentence> sentences,
    QuestionExplanation? explanation,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

/// 問題に表示する選択肢。
@freezed
abstract class AnswerOption with _$AnswerOption {
  const factory AnswerOption({
    required String id,
    required int label,
    required String textJa,
  }) = _AnswerOption;

  factory AnswerOption.fromJson(Map<String, dynamic> json) =>
      _$AnswerOptionFromJson(json);
}

/// 音声内の開始・終了時刻を持つ本文の 1 文。
///
/// プレイヤー位置との照合、文タップによる seek、自動スクロールに使用します。
@freezed
abstract class TranscriptSentence with _$TranscriptSentence {
  const factory TranscriptSentence({
    required String id,
    required int order,
    String? speaker,
    required String textJa,
    String? translationZh,
    @JsonKey(fromJson: _nullableMillisecondsFromJson) int? startMs,
    @JsonKey(fromJson: _nullableMillisecondsFromJson) int? endMs,
  }) = _TranscriptSentence;

  factory TranscriptSentence.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSentenceFromJson(json);
}

/// 問題データの充足状況から、採点と本文同期が利用可能かを判定します。
extension QuestionCapabilities on Question {
  /// 正解IDが実在する選択肢を参照している場合だけ採点可能とします。
  bool get isGradable {
    final correctId = correctOptionId;
    return correctId != null &&
        options.isNotEmpty &&
        options.any((option) => option.id == correctId);
  }

  /// 全文の時刻が順序どおりで、範囲が正しく重複しない場合だけ同期処理を有効にします。
  bool get hasCompleteTimeline {
    if (sentences.isEmpty) return false;
    var previousEnd = -1;
    for (var index = 0; index < sentences.length; index++) {
      final sentence = sentences[index];
      final startMs = sentence.startMs;
      final endMs = sentence.endMs;
      if (sentence.order != index ||
          startMs == null ||
          endMs == null ||
          startMs < 0 ||
          endMs <= startMs ||
          startMs < previousEnd) {
        return false;
      }
      previousEnd = endMs;
    }
    return true;
  }
}

/// 日本語・中国語の解説と、誤答選択肢ごとの補足を保持します。
@freezed
abstract class QuestionExplanation with _$QuestionExplanation {
  const factory QuestionExplanation({
    required String ja,
    required String zh,
    @Default(<String, String>{}) Map<String, String> optionReasonsZh,
  }) = _QuestionExplanation;

  factory QuestionExplanation.fromJson(Map<String, dynamic> json) =>
      _$QuestionExplanationFromJson(json);
}
