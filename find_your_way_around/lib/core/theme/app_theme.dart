import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1B3A6B);
  static const secondary = Color(0xFFC5A028);
  static const background = Color(0xFFF4F6FA);
  static const surface = Colors.white;
  static const onPrimary = Colors.white;
  static const onBackground = Color(0xFF1A1A2E);
  static const cardShadow = Color(0x14000000);
  static const divider = Color(0xFFDDE2EE);
  static const navDark = Color(0xFF152E58);
  static const subtleText = Color(0xFF6B7280);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = GoogleFonts.openSansTextTheme(base.textTheme);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.merriweather(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    textTheme: textTheme.copyWith(
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
      ),
      titleLarge: GoogleFonts.merriweather(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 14,
        color: AppColors.onBackground,
      ),
      bodySmall: GoogleFonts.openSans(
        fontSize: 12,
        color: AppColors.subtleText,
      ),
      labelLarge: GoogleFonts.openSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 6,
      shadowColor: Colors.black26,
      indicatorColor: AppColors.primary.withAlpha(22),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: Color(0xFF9CA3AF));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.openSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          );
        }
        return GoogleFonts.openSans(fontSize: 11, color: const Color(0xFF9CA3AF));
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.openSans(fontSize: 14, color: const Color(0xFFADB5BD)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}
