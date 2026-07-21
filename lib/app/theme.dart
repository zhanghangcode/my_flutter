import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// アプリ固有の色を一元管理するカラートークン。
///
/// 日本の伝統色（濃藍・山吹金・若竹色・朱色・生成り色）を基準にした「墨色東方」
/// パレットです。画面ごとに色値を重複させず、深色 UI と状態色の一貫性を保ちます。
abstract final class AppColors {
  /// アプリ全体で使用する最も暗い背景色です（濃藍）。
  static const background = Color(0xFF10151C);

  /// CardやBottomSheetに使用する標準のsurface色です（藍鉄色）。
  static const surface = Color(0xFF1A222C);

  /// SnackBarなど強調したsurfaceに使用する色です。
  static const surfaceHigh = Color(0xFF222B37);

  /// 主強調色（山吹金）です。再生ボタン、選択状態、進捗表示など「ここぞ」という
  /// 箇所だけに使い、多用しません。
  static const gold = Color(0xFFC6A366);

  /// 金色の弱調です。disabled状態など主張を抑えたい箇所で使用します。
  static const goldDim = Color(0xFF8A7346);

  /// 次強調色（若竹色）です。分類・ラベルなどの副次情報に加え、正答やダウンロード
  /// 済みのような肯定的な状態にも使用します。
  static const jade = Color(0xFF5B7B68);

  /// エラー専用の希少色（朱色）です。誤答やダウンロード失敗など、本当に警告すべき
  /// 場面だけに使用します。
  static const vermillion = Color(0xFFB5502E);

  /// 本文の基本文字色です（生成り色）。長時間の聴解練習でも目に優しい暖白です。
  static const textPrimary = Color(0xFFEDE7DA);

  /// 補助情報・非選択状態の文字色です（鈍色）。
  static const textSecondary = Color(0xFF8A93A0);

  /// disabled状態などさらに弱い文字色です。
  static const textDisabled = Color(0xFF565D68);

  /// 罫線に使用する薄い金色です。
  static const divider = Color(0x1FC6A366);

  /// Cardの縁取りなどに使用する薄い生成り色です。
  static const border = Color(0x14EDE7DA);
}

/// アプリ全体へ適用する Material 3 の Dark Theme を生成します。
///
/// Scaffold、AppBar、Card、NavigationBar などの共通外観をここで定義し、
/// 個別画面が同じデザイン規則を共有できるようにします。
ThemeData buildDarkTheme() {
  // ColorScheme は seedColor から Material コンポーネント用の状態色を生成します。
  // 明示した dark brightness と surface により、深色 UI を基準に配色します。
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.gold,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );

  // 見出しは明朝体で編集組版のような文気を、本文は無衬线のまま読みやすさを保ちます。
  final baseTextTheme = ThemeData(brightness: Brightness.dark).textTheme;
  final textTheme = baseTextTheme.copyWith(
    displayLarge: GoogleFonts.shipporiMincho(
      color: AppColors.textPrimary,
      fontSize: 34,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
    titleLarge: GoogleFonts.shipporiMincho(
      color: AppColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.notoSansJp(
      color: AppColors.textPrimary,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.notoSansJp(
      color: AppColors.textPrimary,
      fontSize: 16,
      height: 1.7,
    ),
    bodyMedium: GoogleFonts.notoSansJp(
      color: AppColors.textSecondary,
      fontSize: 14,
      height: 1.6,
    ),
    labelLarge: GoogleFonts.notoSansJp(
      color: AppColors.gold,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    // Scaffold の背景を統一し、Route 間で背景色が変わらないようにします。
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    dividerColor: AppColors.divider,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.gold.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.textSecondary,
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
        side: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.gold,
      inactiveTrackColor: AppColors.divider,
      thumbColor: AppColors.gold,
      overlayColor: AppColors.gold.withValues(alpha: 0.15),
    ),
  );
}
