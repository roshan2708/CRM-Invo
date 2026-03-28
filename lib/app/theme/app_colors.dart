import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette  deep indigo blue
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Accent
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentLight = Color(0xFF67E8F9);

  // Status colors
  static const Color statusNew = Color(0xFF6366F1);
  static const Color statusContacted = Color(0xFFF59E0B);
  static const Color statusInterested = Color(0xFF10B981);
  static const Color statusConverted = Color(0xFF3B82F6);
  static const Color statusLost = Color(0xFFEF4444);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // Dark theme (True Black)
  static const Color darkBackground = Color(0xFF000000); // True black
  static const Color darkSurface = Color(
    0xFF121212,
  ); // Slightly lighter for surfaces
  static const Color darkCard = Color(0xFF1A1A1A); // Slightly lighter for cards
  static const Color darkBorder = Color(0xFF2C2C2C); // Dark gray borders
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);

  // Common
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Primary color for backgrounds that were previously gradients
  static const Color primaryBackground = Color(0xFF4F46E5);
  static const Color secondaryBackground = Color(0xFF7C3AED);


  // Avatar background colors
  static const List<Color> avatarColors = [
    Color(0xFF4F46E5),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];
}
