import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../application/question_image_provider.dart';
import '../../domain/practice_models.dart';

/// 画像タイプの選択肢に付随する図版を表示するWidget。
///
/// [AnswerOption.hasImage]が`false`の選択肢では何も描画しません。[QuestionImage]と
/// 同じloading/error/dataの構成ですが、選択肢カード内に収まるよう控えめな高さで
/// 表示します。
class AnswerOptionImage extends ConsumerWidget {
  /// 図版を表示する対象の問題・選択肢を受け取ります。
  const AnswerOptionImage({
    super.key,
    required this.question,
    required this.option,
  });

  /// 選択肢が属する問題です。図版のResolverが教材情報の照合に使用します。
  final Question question;

  /// 表示対象となる選択肢です。
  final AnswerOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!option.hasImage) return const SizedBox.shrink();
    final tokens = AppColors.of(context);
    final image = ref.watch(
      answerOptionImageSourceProvider((question, option)),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: image.when(
        loading: () => Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '画像を読み込めませんでした。',
            style: TextStyle(color: tokens.vermillion, fontSize: 13),
          ),
        ),
        data: (source) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 160),
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
