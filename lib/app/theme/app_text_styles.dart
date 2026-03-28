import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.lightText,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.lightText,
      letterSpacing: -0.3,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightText,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextSecondary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.lightText,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.lightText,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.lightTextSecondary,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightText,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextSecondary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.lightTextHint,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.darkText,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.darkText,
      letterSpacing: -0.3,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkText,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextSecondary,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.darkText,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.darkText,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextSecondary,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextSecondary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.darkTextHint,
    ),
  );
}
