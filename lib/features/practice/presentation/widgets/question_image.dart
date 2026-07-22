import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/question_image_provider.dart';
import '../../domain/practice_models.dart';

/// 画像タイプの問題に付随する図版を表示するWidget。
///
/// [Question.hasImage]が`false`の問題では何も描画しません。読み込み中・失敗時も
/// 問題文や選択肢の表示を妨げないよう、控えめな領域だけを占有します。
class QuestionImage extends ConsumerWidget {
  /// 図版を表示する対象の問題を受け取ります。
  const QuestionImage({super.key, required this.question});

  /// 表示対象となる問題です。
  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!question.hasImage) return const SizedBox.shrink();
    final tokens = AppColors.of(context);
    final image = ref.watch(questionImageSourceProvider(question));
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: image.when(
        loading: () => Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(),
        ),
        error: (error, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '画像を読み込めませんでした。',
            style: TextStyle(color: tokens.vermillion),
          ),
        ),
        data: (source) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: source.isAsset
                ? Image.asset(
                    source.path,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  )
                : Image.file(
                    File(source.path),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
          ),
        ),
      ),
    );
  }
}
