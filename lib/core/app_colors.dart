import 'package:flutter/material.dart';

/// Single source of truth for the app's colors.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF7566D9);
  static const Color textDark = Color(0xFF30285E);
  static const Color childText = Color(0xFF25213D);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFFAF8FF);
  static const Color backgroundAlt = Color(0xFFF8F7FF);
  static const Color softPurple = Color(0xFFF0EDFF);
  static const Color border = Color(0xFFEFEAFB);
  static const Color divider = Color(0xFFECE7FF);

  // Secondary text
  static const Color textMuted = Color(0xFF89849F);
  static const Color textSubtle = Color(0xFF817C98);

  // Status and accents
  static const Color successTeal = Color(0xFF43B89C);
  static const Color successGreen = Color(0xFF29A987);
  static const Color amber = Color(0xFFFFB547);
  static const Color orange = Color(0xFFE5A14C);
}
