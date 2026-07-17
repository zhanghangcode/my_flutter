// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExamCatalog _$ExamCatalogFromJson(Map<String, dynamic> json) => _ExamCatalog(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  exams: (json['exams'] as List<dynamic>)
      .map((e) => ExamSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExamCatalogToJson(_ExamCatalog instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'exams': instance.exams,
    };

_ExamSummary _$ExamSummaryFromJson(Map<String, dynamic> json) => _ExamSummary(
  id: json['id'] as String,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  titleJa: json['titleJa'] as String,
  audioQuality: json['audioQuality'] as String,
  questionCount: (json['questionCount'] as num).toInt(),
  resourcePath: json['resourcePath'] as String,
);

Map<String, dynamic> _$ExamSummaryToJson(_ExamSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'titleJa': instance.titleJa,
      'audioQuality': instance.audioQuality,
      'questionCount': instance.questionCount,
      'resourcePath': instance.resourcePath,
    };

_ExamResource _$ExamResourceFromJson(Map<String, dynamic> json) =>
    _ExamResource(
      id: json['id'] as String,
      titleJa: json['titleJa'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamResourceToJson(_ExamResource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleJa': instance.titleJa,
      'questions': instance.questions,
    };

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
  id: json['id'] as String,
  examId: json['examId'] as String,
  section: (json['section'] as num).toInt(),
  number: (json['number'] as num).toInt(),
  type: json['type'] as String,
  promptJa: json['promptJa'] as String,
  options: (json['options'] as List<dynamic>)
      .map((e) => AnswerOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  correctOptionId: json['correctOptionId'] as String,
  audioAssetPath: json['audioAssetPath'] as String,
  sentences: (json['sentences'] as List<dynamic>)
      .map((e) => TranscriptSentence.fromJson(e as Map<String, dynamic>))
      .toList(),
  explanation: QuestionExplanation.fromJson(
    json['explanation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$QuestionToJson(_Question instance) => <String, dynamic>{
  'id': instance.id,
  'examId': instance.examId,
  'section': instance.section,
  'number': instance.number,
  'type': instance.type,
  'promptJa': instance.promptJa,
  'options': instance.options,
  'correctOptionId': instance.correctOptionId,
  'audioAssetPath': instance.audioAssetPath,
  'sentences': instance.sentences,
  'explanation': instance.explanation,
};

_AnswerOption _$AnswerOptionFromJson(Map<String, dynamic> json) =>
    _AnswerOption(
      id: json['id'] as String,
      label: (json['label'] as num).toInt(),
      textJa: json['textJa'] as String,
    );

Map<String, dynamic> _$AnswerOptionToJson(_AnswerOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'textJa': instance.textJa,
    };

_TranscriptSentence _$TranscriptSentenceFromJson(Map<String, dynamic> json) =>
    _TranscriptSentence(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      speaker: json['speaker'] as String?,
      textJa: json['textJa'] as String,
      translationZh: json['translationZh'] as String?,
      startMs: (json['startMs'] as num).toInt(),
      endMs: (json['endMs'] as num).toInt(),
    );

Map<String, dynamic> _$TranscriptSentenceToJson(_TranscriptSentence instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'speaker': instance.speaker,
      'textJa': instance.textJa,
      'translationZh': instance.translationZh,
      'startMs': instance.startMs,
      'endMs': instance.endMs,
    };

_QuestionExplanation _$QuestionExplanationFromJson(Map<String, dynamic> json) =>
    _QuestionExplanation(
      ja: json['ja'] as String,
      zh: json['zh'] as String,
      optionReasonsZh:
          (json['optionReasonsZh'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$QuestionExplanationToJson(
  _QuestionExplanation instance,
) => <String, dynamic>{
  'ja': instance.ja,
  'zh': instance.zh,
  'optionReasonsZh': instance.optionReasonsZh,
};
