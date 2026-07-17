import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/async_states.dart';
import '../../practice/domain/practice_models.dart';

/// お気に入り、誤答、最近の練習を分類して表示する画面。
///
/// DefaultTabController が TabBar と TabBarView の選択状態を同期し、
/// 各タブでは Drift に保存された ID を静的教材のモデルへ関連付けます。
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 全問題を一度取得し、各 StreamProvider の ID と画面内で結合します。
    final questions = ref.watch(allQuestionsProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('お気に入り'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '問題'),
              Tab(text: '文'),
              Tab(text: '間違い'),
              Tab(text: '最近'),
            ],
          ),
        ),
        body: questions.when(
          loading: () => const AppLoadingView(),
          error: (error, _) => AppErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(allQuestionsProvider),
          ),
          data: (items) => TabBarView(
            children: [
              _QuestionIdList(
                questions: items,
                ids:
                    ref.watch(favoriteQuestionIdsProvider).value?.toList() ??
                    [],
                emptyMessage: 'お気に入りの問題はまだありません。',
              ),
              _SentenceList(
                questions: items,
                ids: ref.watch(favoriteSentenceIdsProvider).value ?? {},
              ),
              _QuestionIdList(
                questions: items,
                ids: ref.watch(wrongQuestionIdsProvider).value ?? [],
                emptyMessage: '間違えた問題はありません。',
              ),
              _QuestionIdList(
                questions: items,
                ids: ref.watch(recentQuestionIdsProvider).value ?? [],
                emptyMessage: '最近の練習はありません。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 問題 ID の順序を保ちながら、表示用 Question へ変換する一覧 Widget。
class _QuestionIdList extends StatelessWidget {
  const _QuestionIdList({
    required this.questions,
    required this.ids,
    required this.emptyMessage,
  });

  final List<Question> questions;
  final List<String> ids;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    // ID 検索用 Map を作り、一覧の各行で全件走査しないようにします。
    final byId = {for (final question in questions) question.id: question};
    if (ids.isEmpty) {
      return AppEmptyView(icon: Icons.star_border, message: emptyMessage);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: ids.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final question = byId[ids[index]];
        if (question == null) {
          // 教材更新で参照先がなくなっても、保存記録は自動削除せず明示します。
          return const Card(
            child: ListTile(
              leading: Icon(Icons.warning_amber),
              title: Text('教材が利用できません'),
              subtitle: Text('記録は削除されていません。'),
            ),
          );
        }
        return Card(
          child: ListTile(
            title: Text('問題${question.section}-${question.number}番'),
            subtitle: Text(question.promptJa),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(
              '/practice/${question.examId}/question/${question.id}',
            ),
          ),
        );
      },
    );
  }
}

/// お気に入り文 ID を所属問題と本文へ関連付けて表示する一覧 Widget。
class _SentenceList extends StatelessWidget {
  const _SentenceList({required this.questions, required this.ids});

  final List<Question> questions;
  final Set<String> ids;

  @override
  Widget build(BuildContext context) {
    final matches = <({Question question, TranscriptSentence sentence})>[];
    for (final question in questions) {
      for (final sentence in question.sentences) {
        if (ids.contains(sentence.id)) {
          matches.add((question: question, sentence: sentence));
        }
      }
    }
    if (ids.isEmpty) {
      return const AppEmptyView(
        icon: Icons.format_quote,
        message: 'お気に入りの文はまだありません。',
      );
    }
    if (matches.isEmpty) {
      return const AppEmptyView(
        icon: Icons.warning_amber,
        message: 'お気に入りの教材が利用できません。\n記録は削除されていません。',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(match.sentence.textJa, maxLines: 2),
            subtitle: Text(
              '問題${match.question.section}-${match.question.number}番',
            ),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => context.push(
              '/practice/${match.question.examId}/question/${match.question.id}'
              '?sentenceId=${match.sentence.id}',
            ),
          ),
        );
      },
    );
  }
}
