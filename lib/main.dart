import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// アプリケーションのエントリーポイント。
///
/// Flutter の Binding を初期化した後、ルート Widget を Widget ツリーへ登録します。
void main() {
  // Plugin が利用するプラットフォームチャネルを、runApp より前に使用可能にします。
  WidgetsFlutterBinding.ensureInitialized();

  // runApp はルート Widget を画面へ描画します。ProviderScope を最上位に置くことで、
  // 配下のすべての Widget が同じ Riverpod の ProviderContainer を共有できます。
  runApp(const ProviderScope(child: NihongoListeningApp()));
}
