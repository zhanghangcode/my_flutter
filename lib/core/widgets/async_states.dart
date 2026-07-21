import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 非同期データの読み込み中に共通表示するインジケーター。
class AppLoadingView extends StatelessWidget {
  /// 非同期データの読み込み中表示を生成します。
  ///
  /// [key]は任意のWidget識別子で、生成時に読み込み処理は開始しません。
  const AppLoadingView({super.key});

  @override
  /// 中央配置した読み込みインジケーターを構築します。
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// データが存在しない場合に、理由と次の行動を伝える共通 Widget。
class AppEmptyView extends StatelessWidget {
  /// データ未存在の理由を表示するWidgetを生成します。
  ///
  /// [icon]は状態を示すIcon、[message]は利用者へ表示する説明文です。[key]は任意で、
  /// このWidgetは状態変更や再試行処理を行いません。
  const AppEmptyView({super.key, required this.icon, required this.message});

  /// Empty状態を示すIconDataです。
  final IconData icon;

  /// Empty状態の理由または次の操作を伝える文言です。
  final String message;

  @override
  /// Iconと説明文を中央に配置したEmpty表示を構築します。
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 非同期処理の失敗内容と、任意の再試行操作を表示する共通 Widget。
class AppErrorView extends StatelessWidget {
  /// 非同期処理の失敗内容と任意の再試行操作を表示するWidgetを生成します。
  ///
  /// [message]は表示する失敗内容、[onRetry]は利用者が再試行ボタンを押した時だけ呼ぶ
  /// Callbackです。`null`の場合は再試行ボタンを表示しません。
  const AppErrorView({super.key, required this.message, this.onRetry});

  /// 利用者へ表示するエラー内容です。
  final String message;

  /// 再試行ボタン押下時に実行するCallbackです。`null`なら再試行操作は提供しません。
  final VoidCallback? onRetry;

  @override
  /// エラーIcon、メッセージ、任意の再試行ボタンを構築します。
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.vermillion,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: const Text('再試行')),
            ],
          ],
        ),
      ),
    );
  }
}
