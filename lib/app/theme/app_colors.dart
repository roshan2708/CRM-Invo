import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — slightly more saturated pastel blue
  static const Color primary = Color(0xFF88ABBC);
  static const Color primaryLight = Color(0xFFACD1E2);
  static const Color primaryDark = Color(0xFF5E8594);

  // Accent — slightly more saturated peach/pink
  static const Color accent = Color(0xFFFFB3C6);
  static const Color accentLight = Color(0xFFFFCCDA);

  // Status colors — slightly more saturated
  static const Color statusNew = Color(0xFF9E8BCE); // sat violet
  static const Color statusContacted = Color(0xFFF9D1A3); // sat orange
  static const Color statusInterested = Color(0xFFBBE0B0); // sat green
  static const Color statusConverted = Color(0xFFABC8F4); // sat blue
  static const Color statusLost = Color(0xFFF0A3A3); // sat red

  // Light theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFEFEFEF);
  static const Color lightText = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF777777);
  static const Color lightTextHint = Color(0xFFAAAAAA);

  // Dark theme (Soft Dark)
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF444444);
  static const Color darkText = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextHint = Color(0xFF777777);

  // Common
  static const Color error = Color(0xFFD64D4D);
  static const Color success = Color(0xFF7CB862);
  static const Color warning = Color(0xFFFFC73D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF222222);
  static const Color transparent = Colors.transparent;

  // Solid backgrounds (removing gradient complexity, mapping to solid pastels)
  static const Color primaryBackground = Color(0xFF88ABBC);
  static const Color secondaryBackground = Color(0xFFFFB3C6);

  // Calendar colors
  static const Color calendarSelectedBg = Color(0xFF88ABBC);
  static const Color calendarTodayBg = Color(0xFFEFEFEF);
  static const Color calendarRangeHighlight = Color(0xFFF5F5F5);
  static const Color calendarEventNew = Color(0xFF9E8BCE);
  static const Color calendarEventContacted = Color(0xFFF9D1A3);
  static const Color calendarEventInterested = Color(0xFFBBE0B0);
  static const Color calendarEventConverted = Color(0xFFABC8F4);
  static const Color calendarEventLost = Color(0xFFF0A3A3);

  // Flat alpha colors instead of glassmorphism where simple colors are requested
  static const Color glassLight = Color(0x1A000000); // subtle shadow/overlay instead of bright pop
  static const Color glassDark = Color(0x14FFFFFF);
  static const Color glassBorderLight = Color(0x1A000000);
  static const Color glassBorderDark = Color(0x22FFFFFF);

  // Avatar background colors — pastel array
  static const List<Color> avatarColors = [
    Color(0xFF88ABBC), // Sat Pastel Blue
    Color(0xFFFFB3C6), // Sat Pastel Pink
    Color(0xFF5ED15E), // Sat Pastel Green
    Color(0xFFFFA01A), // Sat Pastel Orange
    Color(0xFF9D83A1), // Sat Pastel Purple
    Color(0xFFFF4D45), // Sat Pastel Red
    Color(0xFFB5B5A6), // Sat Pastel Grey
    Color(0xFFFAFA6E), // Sat Pastel Yellow
  ];

  // Status color lookup
  static Color statusColor(String statusLabel) {
    switch (statusLabel.toLowerCase()) {
      case 'new':
        return statusNew;
      case 'contacted':
        return statusContacted;
      case 'interested':
        return statusInterested;
      case 'converted':
        return statusConverted;
      case 'lost':
        return statusLost;
      default:
        return primary;
    }
  }
}
