import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

/// Theme と Router を組み合わせるアプリ全体のルート Widget。
///
/// `main` の ProviderScope 配下で構築され、各画面に共通のデザインと
/// GoRouter による画面遷移を提供します。
class NihongoListeningApp extends StatelessWidget {
  const NihongoListeningApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router は Navigator を直接組み立てず、appRouter の宣言に従って
    // 表示画面を構築します。Theme もここで一度だけ設定し、全 Route へ継承します。
    return MaterialApp.router(
      title: '聴解トレーニング',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      routerConfig: appRouter,
    );
  }
}
