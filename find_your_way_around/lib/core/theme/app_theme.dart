import 'package:flutter/material.dart';

// Placeholder branding — swap with real Pegasus School colors when confirmed.
class AppColors {
  static const primary = Color(0xFF1A3A6B);      // deep navy
  static const secondary = Color(0xFFD4A017);     // gold accent
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const onPrimary = Colors.white;
  static const onBackground = Color(0xFF1C1C1C);
  static const cardShadow = Color(0x14000000);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.onBackground),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF666666)),
    ),
  );
}
