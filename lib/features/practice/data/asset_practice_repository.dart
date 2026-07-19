import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// Flutter Asset 内の JSON を読み込み、教材モデルへ変換する Repository 実装。
///
/// 読み込んだ catalog と試験をメモリに保持し、同じ Asset の再デコードを避けます。
class AssetPracticeRepository implements PracticeRepository {
  /// Asset Bundleから教材を読み込むRepositoryを生成します。
  ///
  /// [bundle]を指定するとテスト用AssetBundleを注入できます。`null`の場合はFlutterの
  /// [rootBundle]を使用します。生成時にJSONや音声Assetは読み込みません。
  AssetPracticeRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  /// JSONと音声Assetの読み込みに使用するAssetBundleです。
  final AssetBundle _bundle;

  /// 検証済みの教材一覧キャッシュです。未読込時は`null`です。
  ExamCatalog? _catalog;

  /// 試験IDをキーとする検証済み詳細教材のメモリキャッシュです。
  final Map<String, ExamResource> _examCache = {};

  @override
  /// catalogから利用可能な試験一覧を非同期で返します。
  Future<List<ExamSummary>> getExams() async {
    final catalog = await _loadCatalog();
    return catalog.exams;
  }

  @override
  /// 指定試験のJSONと参照音声を検証して非同期で返します。
  ///
  /// [examId]が存在しない、JSON形式が不正、または音声Assetがない場合は
  /// [ContentValidationException]を送出します。
  Future<ExamResource> getExam(String examId) async {
    // 画面間で同じ試験を参照する場合は、検証済みのキャッシュを再利用します。
    final cached = _examCache[examId];
    if (cached != null) return cached;

    final catalog = await _loadCatalog();
    final matches = catalog.exams.where((exam) => exam.id == examId);
    if (matches.isEmpty) {
      throw ContentValidationException('試験データが見つかりません: $examId');
    }
    final summary = matches.single;
    try {
      final source = await _bundle.loadString(summary.resourcePath);
      final resource = ExamResource.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
      // UI へ不整合な教材を渡す前に、ID・正解・時間軸の整合性を確認します。
      _validateResource(resource, summary);
      await _validateAudioAssets(resource);
      _examCache[examId] = resource;
      return resource;
    } on ContentValidationException {
      rethrow;
    } catch (error) {
      throw ContentValidationException(
        '試験データを読み込めませんでした: ${summary.resourcePath}\n$error',
      );
    }
  }

  @override
  /// 全試験を走査して指定問題を非同期で返します。
  ///
  /// [questionId]が見つからない、または試験をまたいで重複する場合は
  /// [ContentValidationException]を送出します。
  Future<Question> getQuestion(String questionId) async {
    final exams = await getExams();
    final matches = <Question>[];
    for (final exam in exams) {
      final resource = await getExam(exam.id);
      for (final question in resource.questions) {
        if (question.id == questionId) matches.add(question);
      }
    }
    if (matches.length > 1) {
      throw ContentValidationException('問題IDが試験間で重複しています: $questionId');
    }
    if (matches case [final question]) return question;
    throw ContentValidationException('問題が見つかりません: $questionId');
  }

  @override
  /// 現在問題から[offset]だけ移動した問題を返します。
  ///
  /// 範囲外の場合は`null`を返します。
  Future<Question?> getAdjacentQuestion(String questionId, int offset) async {
    final current = await getQuestion(questionId);
    final exam = await getExam(current.examId);
    final index = exam.questions.indexWhere((item) => item.id == questionId);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= exam.questions.length) return null;
    return exam.questions[target];
  }

  /// catalog.jsonを読み込み、schemaと試験一覧を検証してキャッシュします。
  ///
  /// キャッシュ済みの場合は同じinstanceを返し、不正な形式は[ContentValidationException]へ変換します。
  Future<ExamCatalog> _loadCatalog() async {
    if (_catalog case final catalog?) return catalog;
    try {
      final source = await _bundle.loadString('assets/data/catalog.json');
      final catalog = ExamCatalog.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
      if (catalog.schemaVersion != 2) {
        throw ContentValidationException(
          '対応していない教材形式です: ${catalog.schemaVersion}',
        );
      }
      // family Provider のキーとして安全に使えるよう、試験 ID の重複を拒否します。
      final ids = <String>{};
      for (final exam in catalog.exams) {
        if (exam.id.isEmpty || exam.resourcePath.isEmpty) {
          throw const ContentValidationException('試験IDまたは教材pathが空です。');
        }
        if (exam.questionCount < 0) {
          throw ContentValidationException('問題数が不正です: ${exam.id}');
        }
        if (!ids.add(exam.id)) {
          throw ContentValidationException('試験IDが重複しています: ${exam.id}');
        }
      }
      _catalog = catalog;
      return catalog;
    } on ContentValidationException {
      rethrow;
    } catch (error) {
      throw ContentValidationException('教材一覧を読み込めませんでした。\n$error');
    }
  }

  /// 試験詳細とcatalogメタデータのID、件数、選択肢、時間軸を検証します。
  ///
  /// [resource]は詳細JSON、[summary]はcatalogの同一試験情報です。不整合は
  /// [ContentValidationException]として送出します。
  void _validateResource(ExamResource resource, ExamSummary summary) {
    if (resource.schemaVersion != 2) {
      throw ContentValidationException(
        '対応していない試験データ形式です: ${resource.schemaVersion}',
      );
    }
    if (resource.id != summary.id) {
      throw const ContentValidationException('試験IDが教材一覧と一致しません。');
    }
    if (resource.questions.length != summary.questionCount) {
      throw const ContentValidationException('問題数が教材一覧と一致しません。');
    }
    final questionIds = <String>{};
    final sentenceIds = <String>{};
    for (final question in resource.questions) {
      if (!questionIds.add(question.id)) {
        throw ContentValidationException('問題IDが重複しています: ${question.id}');
      }
      if (question.examId != resource.id) {
        throw ContentValidationException('問題の試験IDが一致しません: ${question.id}');
      }
      if (question.section <= 0 || question.number <= 0) {
        throw ContentValidationException('問題番号が不正です: ${question.id}');
      }
      if (question.audioAssetPath.isEmpty) {
        throw ContentValidationException('音声pathが空です: ${question.id}');
      }
      final optionIds = <String>{};
      for (final option in question.options) {
        if (option.id.isEmpty || !optionIds.add(option.id)) {
          throw ContentValidationException(
            '選択肢IDが不正または重複しています: ${question.id}',
          );
        }
      }
      if (question.correctOptionId != null && !question.isGradable) {
        throw ContentValidationException('正解の選択肢がありません: ${question.id}');
      }
      if (summary.supportsTest && !question.isGradable) {
        throw ContentValidationException('テスト対象の正解が未収録です: ${question.id}');
      }
      var previousEnd = -1;
      var hasTimedSentence = false;
      var hasUntimedSentence = false;
      for (var index = 0; index < question.sentences.length; index++) {
        final sentence = question.sentences[index];
        if (!sentenceIds.add(sentence.id)) {
          throw ContentValidationException('文IDが重複しています: ${sentence.id}');
        }
        if (sentence.order != index) {
          throw ContentValidationException('文の順序が不正です: ${sentence.id}');
        }
        final startMs = sentence.startMs;
        final endMs = sentence.endMs;
        if ((startMs == null) != (endMs == null)) {
          throw ContentValidationException('時間情報が不正です: ${sentence.id}');
        }
        if (startMs == null) {
          hasUntimedSentence = true;
        } else if (endMs != null) {
          hasTimedSentence = true;
          if (startMs < 0 || endMs <= startMs) {
            throw ContentValidationException('時間情報が不正です: ${sentence.id}');
          }
          if (startMs < previousEnd) {
            throw ContentValidationException('文の時間が重複しています: ${sentence.id}');
          }
          // startMs 順で重複しないことを次の文の検証基準として保持します。
          previousEnd = endMs;
        }
      }
      if (hasTimedSentence && hasUntimedSentence) {
        throw ContentValidationException('時間軸が部分的に設定されています: ${question.id}');
      }
    }
  }

  /// 試験内の各問題が参照する音声Assetの存在と非0-byteを検証します。
  ///
  /// [resource]内のいずれかのAssetを読めない場合は問題IDとpathを含む例外を送出します。
  Future<void> _validateAudioAssets(ExamResource resource) async {
    for (final question in resource.questions) {
      try {
        final data = await _bundle.load(question.audioAssetPath);
        if (data.lengthInBytes == 0) {
          throw StateError('0 byte');
        }
      } catch (error) {
        throw ContentValidationException(
          '音声Assetが見つからないか空です: ${question.id}\n'
          '${question.audioAssetPath}\n$error',
        );
      }
    }
  }
}
