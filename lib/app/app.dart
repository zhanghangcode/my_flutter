import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class NihongoListeningApp extends StatelessWidget {
  const NihongoListeningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '聴解トレーニング',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      routerConfig: appRouter,
    );
  }
}
