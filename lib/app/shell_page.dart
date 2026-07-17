import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 4 つの主要画面と Bottom Navigation をまとめる Shell Widget。
///
/// [StatefulNavigationShell] が選択中 branch と各 branch の Navigator を管理するため、
/// タブを移動しても、それぞれの画面状態とナビゲーション履歴が維持されます。
class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      // SafeArea により、iOS の Home Indicator などと操作領域が重ならないようにします。
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          // currentIndex は選択中 branch と NavigationDestination の表示を同期します。
          selectedIndex: shell.currentIndex,
          // 同じタブを選び直した場合のみ branch の初期 Route へ戻します。
          // 別タブへの切り替えでは、保存済みのナビゲーションスタックを再利用します。
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          // NavigationDestination は各 branch への入口と選択状態の見た目を定義します。
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.headphones_outlined),
              selectedIcon: Icon(Icons.headphones),
              label: '練習',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'テスト',
            ),
            NavigationDestination(
              icon: Icon(Icons.star_outline),
              selectedIcon: Icon(Icons.star),
              label: 'お気に入り',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
