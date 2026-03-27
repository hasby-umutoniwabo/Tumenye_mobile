import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const primary = Color(0xFF3DDC84);
  static const primaryDark = Color(0xFF2ABF6A);
  static const primaryLight = Color(0xFFE8FAF0);
  static const accentOrange = Color(0xFFFF8C42);
  static const accentPurple = Color(0xFF7B61FF);
  static const accentBlue = Color(0xFF4A90E2);
  static const accentYellow = Color(0xFFFFCC00);
  static const accentRed = Color(0xFFFF4B4B);
  static const accentCyan = Color(0xFF00C9A7);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F8FA);
  static const border = Color(0xFFE8EDF0);
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFFADB5BD);
  static const darkBg = Color(0xFF0D1B2A);
  static const darkSurface = Color(0xFF1A2B3C);
  static const darkCard = Color(0xFF1E3248);
  static const darkBorder = Color(0xFF2A3F52);
  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF94A3B8);
}

/// Context-aware color helpers — automatically switch between light and dark values.
extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bgColor => isDark ? AppColors.darkBg : AppColors.background;
  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.surface;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.border;
  Color get textPrimaryColor => isDark ? AppColors.darkText : AppColors.textPrimary;
  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get primaryLightColor =>
      isDark ? AppColors.darkCard : AppColors.primaryLight;
}

abstract class AppTheme {
  static TextTheme _text(TextTheme base) =>
      GoogleFonts.poppinsTextTheme(base).copyWith(
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      );

  static ElevatedButtonThemeData get _btn => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      );

  static InputDecorationTheme _input({bool dark = false}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.darkSurface : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: dark ? AppColors.darkTextSecondary : AppColors.textHint),
      );

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _text(base.textTheme)
          .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
      elevatedButtonTheme: _btn,
      inputDecorationTheme: _input(),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      dividerColor: AppColors.border,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textHint),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.border),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, brightness: Brightness.dark),
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _text(base.textTheme)
          .apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
      elevatedButtonTheme: _btn,
      inputDecorationTheme: _input(dark: true),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkText),
      ),
      dividerColor: AppColors.darkBorder,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.darkTextSecondary),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.darkBorder),
      ),
    );
  }
}