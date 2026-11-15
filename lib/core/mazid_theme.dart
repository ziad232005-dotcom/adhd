import 'package:flutter/material.dart';

/// Brand constants. Change [name] here to rename the app everywhere the
/// design system uses it.
class MazidBrand {
  const MazidBrand._();

  static const String name = 'MΛZID';
  static const String tagline = 'ADHD Parent Support';
}

/// Colors sampled from the UI/UX design.
class MazidColors {
  const MazidColors._();

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
class MazidSpacing {
  const MazidSpacing._();

  static const double screenPadding = 24;
  static const double fieldRadius = 14;
  static const double buttonHeight = 54;
  static const double cardRadius = 20;
}

/// Builds the app-wide [ThemeData] for MΛZID.
class MazidTheme {
  const MazidTheme._();

  static const String fontFamily = 'Cairo';

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(MazidSpacing.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: MazidColors.primary,
      primary: MazidColors.primary,
      surface: MazidColors.surface,
      error: MazidColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MazidColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: MazidColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: MazidColors.textDark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MazidColors.textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MazidColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: MazidColors.textMuted,
          fontSize: 14,
        ),
        prefixIconColor: MazidColors.textMuted,
        suffixIconColor: MazidColors.textMuted,
        border: _border(MazidColors.border),
        enabledBorder: _border(MazidColors.border),
        focusedBorder: _border(MazidColors.primary, 1.6),
        errorBorder: _border(MazidColors.error),
        focusedErrorBorder: _border(MazidColors.error, 1.6),
        errorStyle: const TextStyle(
          color: MazidColors.error,
          fontSize: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        side: const BorderSide(color: MazidColors.border, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MazidColors.primary;
          }
          return MazidColors.surface;
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MazidColors.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: MazidColors.textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: MazidColors.border,
        thickness: 1,
      ),
    );
  }
}
