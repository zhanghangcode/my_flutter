import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice_models.freezed.dart';
part 'practice_models.g.dart';

enum ContentMode { transcript, question, combined, explanation }

enum RepeatMode { none, sentence, question }

@freezed
abstract class ExamCatalog with _$ExamCatalog {
  const factory ExamCatalog({
    required int schemaVersion,
    required List<ExamSummary> exams,
  }) = _ExamCatalog;

  factory ExamCatalog.fromJson(Map<String, dynamic> json) =>
      _$ExamCatalogFromJson(json);
}

@freezed
abstract class ExamSummary with _$ExamSummary {
  const factory ExamSummary({
    required String id,
    required int year,
    required int month,
    required String titleJa,
    required String audioQuality,
    required int questionCount,
    required String resourcePath,
  }) = _ExamSummary;

  factory ExamSummary.fromJson(Map<String, dynamic> json) =>
      _$ExamSummaryFromJson(json);
}

@freezed
abstract class ExamResource with _$ExamResource {
  const factory ExamResource({
    required String id,
    required String titleJa,
    required List<Question> questions,
  }) = _ExamResource;

  factory ExamResource.fromJson(Map<String, dynamic> json) =>
      _$ExamResourceFromJson(json);
}

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
    required String correctOptionId,
    required String audioAssetPath,
    required List<TranscriptSentence> sentences,
    required QuestionExplanation explanation,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

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

@freezed
abstract class TranscriptSentence with _$TranscriptSentence {
  const factory TranscriptSentence({
    required String id,
    required int order,
    String? speaker,
    required String textJa,
    String? translationZh,
    required int startMs,
    required int endMs,
  }) = _TranscriptSentence;

  factory TranscriptSentence.fromJson(Map<String, dynamic> json) =>
      _$TranscriptSentenceFromJson(json);
}

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
