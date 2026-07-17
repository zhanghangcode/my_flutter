import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/practice_detail_controller.dart';
import '../../domain/practice_models.dart';

class AnswerOptions extends ConsumerWidget {
  const AnswerOptions({
    super.key,
    required this.question,
    this.testSelection,
    this.onTestSelect,
    this.showPracticeActions = true,
  });

  final Question question;
  final String? testSelection;
  final ValueChanged<String>? onTestSelect;
  final bool showPracticeActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  final AnswerOption option;
  final bool selected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? AppColors.success
        : isWrong
        ? AppColors.accent
        : selected
        ? Theme.of(context).colorScheme.primary
        : Colors.white24;
    return Material(
      color: AppColors.surface,
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
          child: Row(
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
              if (isCorrect)
                const Icon(Icons.check_circle, color: AppColors.success),
              if (isWrong) const Icon(Icons.cancel, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.success : AppColors.accent).withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? AppColors.success : AppColors.accent,
          ),
          const SizedBox(width: 8),
          Text(isCorrect ? '正解です' : '不正解です'),
        ],
      ),
    );
  }
}
