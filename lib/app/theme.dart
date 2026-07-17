import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF070707);
  static const surface = Color(0xFF202124);
  static const surfaceHigh = Color(0xFF2B2C2F);
  static const accent = Color(0xFFFF3B44);
  static const muted = Color(0xFF9B9B9F);
  static const success = Color(0xFF43A047);
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.dark,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
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
