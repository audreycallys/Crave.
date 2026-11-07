import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double pageTitleSize = 28;
  static const double sectionTitleSize = 17;
  static const double pageSubtitleSize = 13;
  static const double bodyTextSize = 13;
  static const double captionSize = 11;

  static const TextStyle pageTitle = TextStyle(
    fontSize: pageTitleSize,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.7,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: sectionTitleSize,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: pageSubtitleSize,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: bodyTextSize,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: captionSize,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: pageTitleSize,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.7,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: sectionTitleSize,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: bodyTextSize,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: captionSize,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
