import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/practice_detail_controller.dart';
import '../../domain/practice_models.dart';
import 'answer_option_image.dart';

/// 練習モードとテストモードで共有する選択肢一覧。
///
/// 練習では PracticeDetailController の State を購読して採点結果まで表示し、
/// テストでは親から渡された選択値と callback のみを使用して正解を隠します。
class AnswerOptions extends ConsumerWidget {
  /// 練習またはTestの選択肢一覧を生成します。
  ///
  /// [question]は表示・採点対象、[testSelection]と[onTestSelect]はTestモードの親Stateとの
  /// 連携に使用します。[showPracticeActions]が`true`ならPracticeDetailControllerを使い、
  /// `false`なら正解や解説を隠して[onTestSelect]だけを呼びます。
  const AnswerOptions({
    super.key,
    required this.question,
    this.testSelection,
    this.onTestSelect,
    this.showPracticeActions = true,
  });

  /// 選択肢、正解、採点可否を持つ対象問題です。
  final Question question;

  /// Testモードで親から渡される選択中の選択肢IDです。未選択時は`null`です。
  final String? testSelection;

  /// Testモードで選択肢をタップした時に選択肢IDを通知するCallbackです。`null`なら通知しません。
  final ValueChanged<String>? onTestSelect;

  /// `true`なら練習用の採点・再回答操作を表示し、`false`ならTest用表示にします。
  final bool showPracticeActions;

  @override
  /// 問題の採点可否と現在の回答Stateに応じた選択肢UIを構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    if (!question.isGradable) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            '選択肢・正解は未収録です',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.of(context).textSecondary),
          ),
        ),
      );
    }
    // 表示は ref.watch で追従し、タップ時の更新は ref.read で Controller へ委譲します。
    final detail = ref.watch(practiceDetailControllerProvider);
    final selected = showPracticeActions
        ? detail.selectedOptionId
        : testSelection;
    final submitted = showPracticeActions && detail.submitted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in question.options) ...[
          _OptionCard(
            question: question,
            option: option,
            selected: option.id == selected,
            isCorrect: submitted && option.id == question.correctOptionId,
            isWrong:
                submitted &&
                option.id == selected &&
                option.id != question.correctOptionId,
            onTap: () {
              if (showPracticeActions) {
                ref
                    .read(practiceDetailControllerProvider.notifier)
                    .selectOption(option.id);
              } else {
                onTestSelect?.call(option.id);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
        if (showPracticeActions) ...[
          const SizedBox(height: 6),
          if (!submitted)
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () => ref
                        .read(practiceDetailControllerProvider.notifier)
                        .submit(question),
              child: const Text('回答を確認'),
            )
          else ...[
            _ResultBanner(isCorrect: selected == question.correctOptionId),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  ref.read(practiceDetailControllerProvider.notifier).retry(),
              child: const Text('もう一度答える'),
            ),
          ],
        ],
      ],
    );
  }
}

/// 選択・正解・不正解の状態を色とアイコンで表現する 1 選択肢分の Widget。
class _OptionCard extends StatelessWidget {
  /// 1つの選択肢を状態色付きで表示するカードを生成します。
  ///
  /// [question]は[option]が属する問題（画像Resolverの照合に使用）、[option]は
  /// 表示内容、[selected]、[isCorrect]、[isWrong]は表示状態です。[onTap]は利用者が
  /// カードをタップした時に呼ばれます。
  const _OptionCard({
    required this.question,
    required this.option,
    required this.selected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  /// [option]が属する問題です。
  final Question question;

  /// 表示する選択肢です。
  final AnswerOption option;

  /// この選択肢が現在選択されているかを示します。
  final bool selected;

  /// 提出後にこの選択肢が正解として表示されるかを示します。
  final bool isCorrect;

  /// 提出後にこの選択肢が誤答として表示されるかを示します。
  final bool isWrong;

  /// カードタップ時に親へ選択を通知するCallbackです。
  final VoidCallback onTap;

  @override
  /// 選択・正誤に対応する色、番号、本文を含むカードを構築します。
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    final color = isCorrect
        ? tokens.jade
        : isWrong
        ? tokens.vermillion
        : selected
        ? Theme.of(context).colorScheme.primary
        : tokens.border;
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color,
              width: selected || isCorrect ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color),
                    ),
                    child: Text('${option.label}'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.textJa,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  if (isCorrect) Icon(Icons.check_circle, color: tokens.jade),
                  if (isWrong) Icon(Icons.cancel, color: tokens.vermillion),
                ],
              ),
              AnswerOptionImage(question: question, option: option),
            ],
          ),
        ),
      ),
    );
  }
}

/// 提出後の正誤を明示するフィードバック Widget。
class _ResultBanner extends StatelessWidget {
  /// 提出後の正誤フィードバックを生成します。
  ///
  /// [isCorrect]が`true`なら正解、`false`なら不正解の色と文言を表示します。
  const _ResultBanner({required this.isCorrect});

  /// 提出した選択肢が正解かを示します。
  final bool isCorrect;

  @override
  /// 正誤に対応するIconと文言を含むバナーを構築します。
  Widget build(BuildContext context) {
    final tokens = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isCorrect ? tokens.jade : tokens.vermillion).withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? tokens.jade : tokens.vermillion,
          ),
          const SizedBox(width: 8),
          Text(isCorrect ? '正解です' : '不正解です'),
        ],
      ),
    );
  }
}
