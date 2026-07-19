import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice_models.freezed.dart';
part 'practice_models.g.dart';

/// JSON の任意時間値を milliseconds 単位の整数へ変換します。
///
/// [value]が`null`の場合は時間情報なしとして`null`を返し、それ以外は整数だけを
/// 受け付けます。不正な形式は教材の誤りとして[FormatException]を送出します。
int? _nullableMillisecondsFromJson(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException('文時間は整数millisecondsで指定してください: $value');
}

/// 練習詳細で切り替えられる4種類の表示モード。
enum ContentMode {
  /// 音声と同期するTranscriptだけを表示します。
  transcript,

  /// 問題文と選択肢だけを表示します。
  question,

  /// Transcriptと問題文・選択肢を同じ画面に表示します。
  combined,

  /// 日本語・中国語の解説を表示します。
  explanation,
}

/// 教材一覧 JSON のルートモデル。
///
/// schemaVersion により、アプリが対応できる教材形式かを読み込み時に判定します。
@freezed
abstract class ExamCatalog with _$ExamCatalog {
  /// 教材一覧のルート値を生成します。
  ///
  /// [schemaVersion]はJSON形式の互換性を示す整数、[exams]は一覧へ表示する試験の
  /// メタデータです。生成時にI/Oや状態変更は行いません。
  const factory ExamCatalog({
    required int schemaVersion,
    required List<ExamSummary> exams,
  }) = _ExamCatalog;

  /// JSONから教材一覧を復元します。
  ///
  /// [json]の形式がモデル定義と一致しない場合はJSON変換例外が発生します。
  factory ExamCatalog.fromJson(Map<String, dynamic> json) =>
      _$ExamCatalogFromJson(json);
}

/// 一覧画面に必要な試験メタデータと、詳細 JSON の参照先を表します。
@freezed
abstract class ExamSummary with _$ExamSummary {
  /// 一覧表示用の試験メタデータを生成します。
  ///
  /// [id]は試験の一意な識別子、[year]と[month]は試験年月です。年月が未設定の教材は
  /// どちらも`null`です。[resourcePath]は詳細JSONのAsset相対path、[supportsTest]は
  /// 採点可能なTestモードを提供するかを示します。生成時の副作用はありません。
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

  /// JSONから試験メタデータを復元します。
  factory ExamSummary.fromJson(Map<String, dynamic> json) =>
      _$ExamSummaryFromJson(json);
}

/// 1 回分の試験情報と、その試験に含まれる問題一覧を表します。
@freezed
abstract class ExamResource with _$ExamResource {
  /// 試験の詳細データを生成します。
  ///
  /// [schemaVersion]は詳細JSONの形式、[id]と[titleJa]は試験の識別・表示情報、
  /// [questions]は表示順を保った問題一覧です。生成時にI/Oは行いません。
  const factory ExamResource({
    required int schemaVersion,
    required String id,
    required String titleJa,
    required List<Question> questions,
  }) = _ExamResource;

  /// JSONから試験詳細を復元します。
  factory ExamResource.fromJson(Map<String, dynamic> json) =>
      _$ExamResourceFromJson(json);
}

/// 音声、時間付き本文、選択肢、正解、解説をまとめた 1 問分のモデル。
@freezed
abstract class Question with _$Question {
  /// 1問分の教材データを生成します。
  ///
  /// [id]は全教材で一意な問題ID、[examId]は所属試験IDです。[section]と[number]は
  /// 表示する問題番号、[audioAssetPath]は対応する音声Assetの相対pathです。
  /// [correctOptionId]が`null`の場合は採点情報未収録、[explanation]が`null`の場合は
  /// 解説未収録を表します。[sentences]の時間は問題音声の先頭を基準にします。
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

  /// JSONから問題データを復元します。
  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

/// 問題に表示する選択肢。
@freezed
abstract class AnswerOption with _$AnswerOption {
  /// 問題に表示する選択肢を生成します。
  ///
  /// [id]は正解・回答記録で使用する安定ID、[label]は画面上の番号、[textJa]は
  /// 日本語の選択肢本文です。生成時の副作用はありません。
  const factory AnswerOption({
    required String id,
    required int label,
    required String textJa,
  }) = _AnswerOption;

  /// JSONから選択肢を復元します。
  factory AnswerOption.fromJson(Map<String, dynamic> json) =>
      _$AnswerOptionFromJson(json);
}

/// 音声内の開始・終了時刻を持つ本文の 1 文。
///
/// プレイヤー位置との照合、文タップによる seek、自動スクロールに使用します。
@freezed
abstract class TranscriptSentence with _$TranscriptSentence {
  /// 音声内の1文を生成します。
  ///
  /// [id]は文のお気に入りと同期で使用する安定ID、[order]は問題内の0始まりの表示順です。
  /// [speaker]と[translationZh]が`null`の場合は、それぞれ話者名と中国語訳を表示しません。
  /// [startMs]と[endMs]は問題音声の先頭を`0`とするmilliseconds単位の相対時刻で、
  /// どちらかが`null`の場合は文単位同期を利用できません。
  const factory TranscriptSentence({
    required String id,
    required int order,
    String? speaker,
    required String textJa,
    String? translationZh,
    @JsonKey(fromJson: _nullableMillisecondsFromJson) int? startMs,
    @JsonKey(fromJson: _nullableMillisecondsFromJson) int? endMs,
  }) = _TranscriptSentence;

  /// JSONからTranscriptの1文を復元します。
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
  /// 問題の解説を生成します。
  ///
  /// [ja]と[zh]は解説本文、[optionReasonsZh]は選択肢IDをキーとする中国語の補足です。
  /// [optionReasonsZh]を省略した場合は空のMapを使用し、生成時の副作用はありません。
  const factory QuestionExplanation({
    required String ja,
    required String zh,
    @Default(<String, String>{}) Map<String, String> optionReasonsZh,
  }) = _QuestionExplanation;

  /// JSONから問題解説を復元します。
  factory QuestionExplanation.fromJson(Map<String, dynamic> json) =>
      _$QuestionExplanationFromJson(json);
}
