import 'dart:io';

import '../../practice/domain/practice_models.dart';

/// 試験単位のZIPを取得し、一時ファイルへ保存する取得元の抽象化。
///
/// R2 HTTPとBundle Assetを使うMockを同じInterfaceで扱い、解凍・検証・Manifest保存は
/// Repositoryへ集約します。
abstract interface class DownloadSource {
  /// [summary]に対応するZIPを[destination]へ保存します。
  ///
  /// [onProgress]にはネットワークまたは生成処理の進捗を`0.0`〜`1.0`で通知します。
  Future<void> downloadArchive(
    ExamSummary summary,
    ExamResource resource,
    File destination, {
    required void Function(double progress) onProgress,
  });
}
