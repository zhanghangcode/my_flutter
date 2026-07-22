import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../downloads/application/download_controller.dart';
import '../../downloads/data/local_question_image_resolver.dart';
import '../domain/practice_models.dart';
import '../domain/question_image_resolver.dart';
import '../domain/question_image_source.dart';

/// 教材の配送方式に応じてAsset/Fileを決定するQuestionImageResolverを提供します。
final questionImageResolverProvider = Provider<QuestionImageResolver>(
  (ref) => LocalQuestionImageResolver(
    ref.watch(practiceRepositoryProvider),
    ref.watch(downloadRepositoryProvider),
  ),
);

/// [Question.hasImage]な問題1件分の表示可能な図版を解決するfamily Provider。
///
/// 画像を持たない問題では呼び出さないでください（Widget側で[Question.hasImage]を
/// 事前に確認します）。
final questionImageSourceProvider =
    FutureProvider.family<QuestionImageSource, Question>(
      (ref, question) =>
          ref.watch(questionImageResolverProvider).resolve(question),
    );
