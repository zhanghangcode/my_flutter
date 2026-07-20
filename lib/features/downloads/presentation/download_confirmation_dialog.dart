import 'package:flutter/material.dart';

import '../../practice/domain/practice_models.dart';

/// Download必須教材を開く前に、端末保存の同意を確認するDialogを表示します。
Future<bool> showExamDownloadConfirmation(
  BuildContext context,
  ExamSummary exam,
) async {
  final label = exam.year != null && exam.month != null
      ? '${exam.year}年${exam.month}月'
      : exam.titleJa;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('音声データをダウンロードしますか？'),
          content: Text(
            '$labelの音声データを端末にダウンロードします。\n'
            'ダウンロード後はオフラインでも再生できます。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ダウンロード'),
            ),
          ],
        ),
      ) ??
      false;
}

/// 内部pathを含めず、Download失敗を利用者へ案内する共通SnackBarを表示します。
void showExamDownloadError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('音声データのダウンロードに失敗しました。もう一度お試しください。')),
  );
}
