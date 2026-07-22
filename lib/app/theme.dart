import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 「墨色東方」パレットのライト/ダーク双方の色値をまとめる ThemeExtension。
///
/// 日本の伝統色（濃藍・山吹金・若竹色・朱色・生成り色）を基準にした配色を、
/// [Brightness]ごとに異なる具体値として保持します。Widget側は[AppColors.of]経由で
/// 現在のThemeに登録された値を参照するため、色値をコンパイル時定数として直接
/// 埋め込まず、実行時のテーマ切替に追従できます。
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  /// 全トークンを指定して色セットを生成します。
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.gold,
    required this.goldDim,
    required this.jade,
    required this.vermillion,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.divider,
    required this.border,
  });

  /// アプリ全体で使用する最も基調となる背景色です（濃藍／生成り紙）。
  final Color background;

  /// CardやBottomSheetに使用する標準のsurface色です（藍鉄色／白）。
  final Color surface;

  /// SnackBarなど強調したsurfaceに使用する色です。
  final Color surfaceHigh;

  /// 主強調色（山吹金）です。再生ボタン、選択状態、進捗表示など「ここぞ」という
  /// 箇所だけに使い、多用しません。
  final Color gold;

  /// 金色の弱調です。disabled状態など主張を抑えたい箇所で使用します。
  final Color goldDim;

  /// 次強調色（若竹色）です。分類・ラベルなどの副次情報に加え、正答やダウンロード
  /// 済みのような肯定的な状態にも使用します。
  final Color jade;

  /// エラー専用の希少色（朱色）です。誤答やダウンロード失敗など、本当に警告すべき
  /// 場面だけに使用します。
  final Color vermillion;

  /// 本文の基本文字色です（生成り色／墨色）。
  final Color textPrimary;

  /// 補助情報・非選択状態の文字色です（鈍色）。
  final Color textSecondary;

  /// disabled状態などさらに弱い文字色です。
  final Color textDisabled;

  /// 罫線に使用する薄い金色です。
  final Color divider;

  /// Cardの縁取りなどに使用する薄い色です。
  final Color border;

  /// 濃藍を基調にしたDark Theme用の色セットです。
  static const dark = AppColorTokens(
    background: Color(0xFF10151C),
    surface: Color(0xFF1A222C),
    surfaceHigh: Color(0xFF222B37),
    gold: Color(0xFFC6A366),
    goldDim: Color(0xFF8A7346),
    jade: Color(0xFF5B7B68),
    vermillion: Color(0xFFB5502E),
    textPrimary: Color(0xFFEDE7DA),
    textSecondary: Color(0xFF8A93A0),
    textDisabled: Color(0xFF565D68),
    divider: Color(0x1FC6A366),
    border: Color(0x14EDE7DA),
  );

  /// 生成り紙に墨で書いたようなLight Theme用の色セットです。ダークと同じ配色言語を
  /// 保ちつつ、白背景でも十分なコントラストを確保するよう強調色を深めています。
  static const light = AppColorTokens(
    background: Color(0xFFF7F3EC),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFEFEAE0),
    gold: Color(0xFFA9793B),
    goldDim: Color(0xFFD9C39A),
    jade: Color(0xFF3F5D4C),
    vermillion: Color(0xFF9C3D22),
    textPrimary: Color(0xFF231F1B),
    textSecondary: Color(0xFF6B6259),
    textDisabled: Color(0xFFAFA695),
    divider: Color(0x33A9793B),
    border: Color(0x1F231F1B),
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? gold,
    Color? goldDim,
    Color? jade,
    Color? vermillion,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? divider,
    Color? border,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      gold: gold ?? this.gold,
      goldDim: goldDim ?? this.goldDim,
      jade: jade ?? this.jade,
      vermillion: vermillion ?? this.vermillion,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      divider: divider ?? this.divider,
      border: border ?? this.border,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldDim: Color.lerp(goldDim, other.goldDim, t)!,
      jade: Color.lerp(jade, other.jade, t)!,
      vermillion: Color.lerp(vermillion, other.vermillion, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// 現在のThemeに登録された[AppColorTokens]を参照するためのアクセサ。
///
/// 色値そのものは保持せず、Widgetから`AppColors.of(context).gold`のように
/// 呼び出すことで、ライト/ダーク切替に追従した色を取得します。
abstract final class AppColors {
  /// [context]が属するThemeの[AppColorTokens]を返します。
  static AppColorTokens of(BuildContext context) =>
      Theme.of(context).extension<AppColorTokens>()!;
}

/// アプリ全体へ適用する Material 3 の Dark Theme を生成します。
ThemeData buildDarkTheme() => _buildTheme(AppColorTokens.dark, Brightness.dark);

/// アプリ全体へ適用する Material 3 の Light Theme を生成します。
ThemeData buildLightTheme() =>
    _buildTheme(AppColorTokens.light, Brightness.light);

/// [tokens]と[brightness]から共通のTheme構築ロジックを適用したThemeDataを生成します。
///
/// Scaffold、AppBar、Card、NavigationBar などの共通外観をここで定義し、
/// 個別画面が同じデザイン規則を共有できるようにします。
ThemeData _buildTheme(AppColorTokens tokens, Brightness brightness) {
  // ColorScheme は seedColor から Material コンポーネント用の状態色を生成します。
  // 明示した brightness と surface により、tokensを基準に配色します。
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.gold,
    brightness: brightness,
    surface: tokens.surface,
  );

  // 見出しは明朝体で編集組版のような文気を、本文は無衬线のまま読みやすさを保ちます。
  final baseTextTheme = ThemeData(brightness: brightness).textTheme;
  final textTheme = baseTextTheme.copyWith(
    displayLarge: GoogleFonts.shipporiMincho(
      color: tokens.textPrimary,
      fontSize: 34,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
    titleLarge: GoogleFonts.shipporiMincho(
      color: tokens.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.notoSansJp(
      color: tokens.textPrimary,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.notoSansJp(
      color: tokens.textPrimary,
      fontSize: 16,
      height: 1.7,
    ),
    bodyMedium: GoogleFonts.notoSansJp(
      color: tokens.textSecondary,
      fontSize: 14,
      height: 1.6,
    ),
    labelLarge: GoogleFonts.notoSansJp(
      color: tokens.gold,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [tokens],
    // Scaffold の背景を統一し、Route 間で背景色が変わらないようにします。
    scaffoldBackgroundColor: tokens.background,
    cardColor: tokens.surface,
    dividerColor: tokens.divider,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.background,
      foregroundColor: tokens.textPrimary,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.background,
      indicatorColor: tokens.gold.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? tokens.textPrimary
              : tokens.textSecondary,
          fontSize: 12,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: tokens.border, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: tokens.surfaceHigh,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: tokens.gold,
      inactiveTrackColor: tokens.divider,
      thumbColor: tokens.gold,
      overlayColor: tokens.gold.withValues(alpha: 0.15),
    ),
  );
}
