import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';
import '../domain/practice_models.dart';

/// 選択した試験に含まれる問題を、section（問題番号）単位に一覧表示する画面。
///
/// PracticeListPage で試験年月を選択した後に表示し、行タップで対応する問題の
/// 練習詳細画面（音声再生）へ遷移します。試験一覧へは AppBar の戻るボタンで戻れます。
class QuestionListPage extends ConsumerWidget {
  /// 表示対象の試験IDを受け取り、問題一覧画面を生成します。
  ///
  /// [examId]は[examResourceProvider]で試験詳細を取得するためのキーです。生成時に
  /// 読み込みは開始しません。
  const QuestionListPage({super.key, required this.examId});

  /// 表示・取得対象の試験の一意なIDです。
  final String examId;

  @override
  /// 試験詳細Providerの状態に応じて、section単位の問題一覧UIを構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    final resource = ref.watch(examResourceProvider(examId));
    return Scaffold(
      appBar: AppBar(
        title: resource.maybeWhen(
          data: (exam) => Text(exam.titleJa),
          orElse: () => const Text('問題一覧'),
        ),
      ),
      body: resource.when(
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(examResourceProvider(examId)),
        ),
        data: (exam) {
          if (exam.questions.isEmpty) {
            return const AppEmptyView(
              icon: Icons.quiz_outlined,
              message: 'この試験には問題がありません。',
            );
          }
          // 登場順を保ったまま、同じsection（問題番号）の問題をまとめて表示します。
          final sections = <int, List<Question>>{};
          for (final question in exam.questions) {
            sections.putIfAbsent(question.section, () => []).add(question);
          }
          final sectionKeys = sections.keys.toList()..sort();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: sectionKeys.length,
            itemBuilder: (context, index) {
              final section = sectionKeys[index];
              final questions = sections[section]!;
              return _SectionCard(
                examId: examId,
                section: section,
                // sectionごとの種別表示は先頭の問題のtypeを代表値として使用します。
                typeLabel: questions.first.type,
                questions: questions,
              );
            },
          );
        },
      ),
    );
  }
}

/// 1つのsection（問題番号）の見出しと、配下の問題行をまとめて表示するカード。
class _SectionCard extends StatelessWidget {
  /// section見出しと問題行の一覧を表示するカードを生成します。
  ///
  /// [examId]は各問題行の遷移先を組み立てるための試験ID、[section]は表示する
  /// 問題番号、[typeLabel]は見出しに表示する問題種別、[questions]は同じsection内で
  /// number順に並んだ問題一覧です。
  const _SectionCard({
    required this.examId,
    required this.section,
    required this.typeLabel,
    required this.questions,
  });

  /// 各問題行の遷移先path組み立てに使用する試験IDです。
  final String examId;

  /// 見出しに表示する問題番号（例: 問題1）です。
  final int section;

  /// 見出しに表示する問題種別（例: 課題理解）です。
  final String typeLabel;

  /// このsectionに属する問題一覧です。
  final List<Question> questions;

  @override
  /// section見出しをタップで開閉できるCardとして構築します。既定は折りたたみ状態です。
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(
          '問題$section $typeLabel',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          for (final question in questions)
            ListTile(
              title: Text('第${question.number}問'),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () =>
                  context.push('/practice/$examId/question/${question.id}'),
            ),
        ],
      ),
    );
  }
}
