import 'package:flutter/material.dart';

/// アプリ固有の色を一元管理するカラートークン。
///
/// 画面ごとに色値を重複させず、深色 UI と状態色の一貫性を保ちます。
abstract final class AppColors {
  /// アプリ全体で使用する最も暗い背景色です。
  static const background = Color(0xFF070707);

  /// CardやBottomSheetに使用する標準のsurface色です。
  static const surface = Color(0xFF202124);

  /// SnackBarなど強調したsurfaceに使用する色です。
  static const surfaceHigh = Color(0xFF2B2C2F);

  /// 活性文やエラー表示に使用するアクセント色です。
  static const accent = Color(0xFFFF3B44);

  /// 非選択テキストなど補助情報に使用する色です。
  static const muted = Color(0xFF9B9B9F);

  /// 正答など成功状態に使用する色です。
  static const success = Color(0xFF43A047);
}

/// アプリ全体へ適用する Material 3 の Dark Theme を生成します。
///
/// Scaffold、AppBar、Card、NavigationBar などの共通外観をここで定義し、
/// 個別画面が同じデザイン規則を共有できるようにします。
ThemeData buildDarkTheme() {
  // ColorScheme は seedColor から Material コンポーネント用の状態色を生成します。
  // 明示した dark brightness と surface により、深色 UI を基準に配色します。
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    // Scaffold の背景を統一し、Route 間で背景色が変わらないようにします。
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    dividerColor: Colors.white24,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF151515),
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.muted,
          fontSize: 12,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Colors.white,
      inactiveTrackColor: Colors.white24,
      thumbColor: Colors.white,
      overlayColor: Colors.white12,
    ),
  );
}
