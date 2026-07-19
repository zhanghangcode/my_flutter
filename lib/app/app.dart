import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

/// Theme と Router を組み合わせるアプリ全体のルート Widget。
///
/// `main` の ProviderScope 配下で構築され、各画面に共通のデザインと
/// GoRouter による画面遷移を提供します。
class NihongoListeningApp extends StatelessWidget {
  /// アプリ全体のThemeとRouterを提供するルートWidgetを生成します。
  ///
  /// [key]はWidgetツリー内でこのWidgetを識別する任意のKeyです。生成時に
  /// ProviderやRouteを直接初期化する副作用はありません。
  const NihongoListeningApp({super.key});

  @override
  /// MaterialApp.routerを構築してThemeとGoRouter設定を全画面へ適用します。
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
