import 'package:flutter/material.dart';

/// Brand constants. Change [name] here to rename the app everywhere the
/// design system uses it.
class BloomBrand {
  const BloomBrand._();

  static const String name = 'MΛZID';
  static const String tagline = 'ADHD Parent Support';
}

/// Colors sampled from the Bloom UI/UX design.
class BloomColors {
  const BloomColors._();

  static const Color primary = Color(0xFF6557D9);
  static const Color primaryBright = Color(0xFF7664E8);

  static const Color background = Color(0xFFFBFAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color softPurple = Color(0xFFF0EDFF);
  static const Color wave = Color(0xFFEEE9FF);

  static const Color textDark = Color(0xFF201B52);
  static const Color textBody = Color(0xFF28243A);
  static const Color textMuted = Color(0xFF6E6985);

  static const Color border = Color(0xFFE7E6F1);

  static const Color success = Color(0xFF1E8E5F);
  static const Color successSoft = Color(0xFFE0F5EB);

  static const Color pink = Color(0xFFE8708F);
  static const Color pinkSoft = Color(0xFFFDE7EE);

  static const Color error = Color(0xFFD64545);
  static const Color errorSoft = Color(0xFFFDECEC);
}

/// Spacing and radius values shared by all screens.
class BloomSpacing {
  const BloomSpacing._();

  static const double screenPadding = 24;
  static const double fieldRadius = 14;
  static const double buttonHeight = 54;
  static const double cardRadius = 20;
}

/// Builds the app-wide [ThemeData] for Bloom.
class BloomTheme {
  const BloomTheme._();

  static const String fontFamily = 'Cairo';

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(BloomSpacing.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: BloomColors.primary,
      primary: BloomColors.primary,
      surface: BloomColors.surface,
      error: BloomColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BloomColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: BloomColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: BloomColors.textDark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: BloomColors.textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BloomColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: BloomColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: BloomColors.textMuted,
        suffixIconColor: BloomColors.textMuted,
        border: _border(BloomColors.border),
        enabledBorder: _border(BloomColors.border),
        focusedBorder: _border(BloomColors.primary, 1.6),
        errorBorder: _border(BloomColors.error),
        focusedErrorBorder: _border(BloomColors.error, 1.6),
        errorStyle: const TextStyle(
          color: BloomColors.error,
          fontSize: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(color: BloomColors.border, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BloomColors.primary;
          }
          return BloomColors.surface;
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BloomColors.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BloomColors.textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BloomColors.border,
        thickness: 1,
      ),
    );
  }
}
