import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/async_states.dart';

/// 再生・表示設定と学習データ管理を提供する設定画面。
///
/// Scaffold と AppBar で主画面の枠を作り、設定の非同期状態に応じて内容を切り替えます。
/// 各操作は SettingsController または LearningRepository へ委譲します。
class SettingsPage extends ConsumerWidget {
  /// 再生・表示・学習データ設定を表示する画面を生成します。
  ///
  /// [key]は任意のWidget識別子で、設定の読み込みはProvider購読時に開始されます。
  const SettingsPage({super.key});

  @override
  /// 設定Providerの非同期状態に応じた設定画面を構築します。
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch により、保存直前に更新された設定値を各入力 Widget へ即時反映します。
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: settings.when(
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(settingsControllerProvider),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const _SectionTitle('再生'),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('標準の再生速度'),
              trailing: DropdownButton<double>(
                value: value.defaultSpeed,
                underline: const SizedBox.shrink(),
                items: [
                  for (final speed in <double>[
                    0.5,
                    0.75,
                    1,
                    1.25,
                    1.5,
                    1.75,
                    2,
                  ])
                    DropdownMenuItem(value: speed, child: Text('${speed}x')),
                ],
                onChanged: (speed) {
                  if (speed != null) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .saveChanges(
                          (current) => current.copyWith(defaultSpeed: speed),
                        );
                  }
                },
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vertical_align_center),
              title: const Text('再生中に自動スクロール'),
              value: value.autoScroll,
              onChanged: (enabled) => ref
                  .read(settingsControllerProvider.notifier)
                  .saveChanges(
                    (current) => current.copyWith(autoScroll: enabled),
                  ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.restore),
              title: const Text('前回の再生位置を記憶'),
              value: value.rememberPosition,
              onChanged: (enabled) => ref
                  .read(settingsControllerProvider.notifier)
                  .saveChanges(
                    (current) => current.copyWith(rememberPosition: enabled),
                  ),
            ),
            const _SectionTitle('表示'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.brightness_6),
                      SizedBox(width: 16),
                      Text('テーマ'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('ライト'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('ダーク'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('自動'),
                      ),
                    ],
                    selected: {value.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) => ref
                        .read(settingsControllerProvider.notifier)
                        .saveChanges(
                          (current) =>
                              current.copyWith(themeMode: selection.first),
                        ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.translate),
              title: const Text('中国語の翻訳を表示'),
              value: value.showChinese,
              onChanged: (enabled) => ref
                  .read(settingsControllerProvider.notifier)
                  .saveChanges(
                    (current) => current.copyWith(showChinese: enabled),
                  ),
            ),
            const _SectionTitle('データ'),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('学習記録を消去'),
              subtitle: const Text('回答、進捗、お気に入り、テスト結果を削除します'),
              onTap: () => _confirmClear(context, ref),
            ),
            const _SectionTitle('アプリ情報'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('聴解トレーニング'),
              subtitle: Text('バージョン 1.0.0 ・ オフライン体験版'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '収録された問題と音声は、このアプリのデモ用に作成されたオリジナル教材です。',
                style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 学習記録の全削除を確認し、同意時だけRepositoryへ削除を依頼します。
  ///
  /// [context]はDialogとSnackBar、[ref]はLearningRepositoryの取得に使用します。キャンセル時は
  /// 何も変更せず、削除完了後にWidgetが破棄済みならSnackBarを表示しません。
  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    // 破壊的操作は確認 Dialog を通し、明示的に同意された場合だけ実行します。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('学習記録を消去しますか？'),
        content: const Text('この操作は取り消せません。教材は削除されません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('消去'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(learningRepositoryProvider).clearAll();
    // DB 処理中に画面が破棄されていない場合だけ SnackBar を表示します。
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('学習記録を消去しました。')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  /// 設定一覧の区分見出しを生成します。
  ///
  /// [text]は表示する見出し文言です。
  const _SectionTitle(this.text);

  /// 表示する設定区分の文言です。
  final String text;

  @override
  /// Themeのprimary色を使用した見出し行を構築します。
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
