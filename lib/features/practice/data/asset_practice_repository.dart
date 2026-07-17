import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

class AssetPracticeRepository implements PracticeRepository {
  AssetPracticeRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  ExamCatalog? _catalog;
  final Map<String, ExamResource> _examCache = {};

  @override
  Future<List<ExamSummary>> getExams() async {
    final catalog = await _loadCatalog();
    return catalog.exams;
  }

  @override
  Future<ExamResource> getExam(String examId) async {
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
      _validateResource(resource, summary);
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
  Future<Question> getQuestion(String questionId) async {
    final exams = await getExams();
    for (final exam in exams) {
      final resource = await getExam(exam.id);
      for (final question in resource.questions) {
        if (question.id == questionId) return question;
      }
    }
    throw ContentValidationException('問題が見つかりません: $questionId');
  }

  @override
  Future<Question?> getAdjacentQuestion(String questionId, int offset) async {
    final current = await getQuestion(questionId);
    final exam = await getExam(current.examId);
    final index = exam.questions.indexWhere((item) => item.id == questionId);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= exam.questions.length) return null;
    return exam.questions[target];
  }

  Future<ExamCatalog> _loadCatalog() async {
    if (_catalog case final catalog?) return catalog;
    try {
      final source = await _bundle.loadString('assets/data/catalog.json');
      final catalog = ExamCatalog.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );
      if (catalog.schemaVersion != 1) {
        throw ContentValidationException(
          '対応していない教材形式です: ${catalog.schemaVersion}',
        );
      }
      final ids = <String>{};
      for (final exam in catalog.exams) {
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

  void _validateResource(ExamResource resource, ExamSummary summary) {
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
      if (!question.options.any(
        (item) => item.id == question.correctOptionId,
      )) {
        throw ContentValidationException('正解の選択肢がありません: ${question.id}');
      }
      var previousEnd = -1;
      for (final sentence in question.sentences) {
        if (!sentenceIds.add(sentence.id)) {
          throw ContentValidationException('文IDが重複しています: ${sentence.id}');
        }
        if (sentence.startMs < 0 || sentence.endMs <= sentence.startMs) {
          throw ContentValidationException('時間情報が不正です: ${sentence.id}');
        }
        if (sentence.startMs < previousEnd) {
          throw ContentValidationException('文の時間が重複しています: ${sentence.id}');
        }
        previousEnd = sentence.endMs;
      }
    }
  }
}
