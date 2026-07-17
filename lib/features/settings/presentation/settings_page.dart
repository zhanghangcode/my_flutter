import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/async_states.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '収録された問題と音声は、このアプリのデモ用に作成されたオリジナル教材です。',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
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
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('学習記録を消去しました。')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
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
