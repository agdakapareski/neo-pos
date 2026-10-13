import 'package:flutter/material.dart';

/// Design tokens extracted from the Stitch mockups in `design/stitch/`
/// (Tailwind config in the exported HTML).
///
/// Visual direction: monochrome "receipt-tape" terminal style.
/// All text uses the platform monospace font (Space Mono look, no font asset).
class AppTheme {
  // Monospace font (system generic family, no bundled asset).
  static const String fontFamily = 'monospace';

  // --- Color tokens (from Stitch Tailwind config) ---
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF4C4546);
  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);

  // --- Spacing tokens ---
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 40;
  static const double gutter = 16;

  // --- Radius tokens ---
  static const double radiusSm = 4;
  static const double radiusLg = 8;
  static const double radiusXl = 12;

  // --- Typography (mono, uppercase labels get letterSpacing) ---
  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: -0.28,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 28 / 20,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle headlineSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.64,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle labelLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 18 / 14,
    letterSpacing: 1.12,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );
  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.24,
    fontWeight: FontWeight.w400,
    color: onSurface,
  );

  // Legacy aliases kept so older screens keep compiling.
  static const Color primaryColor = primary;
  static const Color accentColor = outline;
  static const Color backgroundColor = surface;
  static const Color surfaceColor = surfaceContainerLowest;
  static const Color errorColor = error;
  static const Color successColor = onSurface;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color dividerColor = outlineVariant;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      primaryColor: primary,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: outline,
        onSecondary: onError,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headlineSm,
        iconTheme: IconThemeData(color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: spaceSm + 4,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          ),
          textStyle: labelMd,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: onSurface),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: spaceSm + 4,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          ),
          textStyle: labelMd,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: onSurface,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: spaceSm,
          ),
          textStyle: labelMd,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceSm + 4,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: onSurface, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: error),
        ),
        labelStyle: bodyMd.copyWith(color: onSurfaceVariant),
        hintStyle: bodyMd.copyWith(color: outline),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          side: BorderSide(color: outlineVariant),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : surfaceContainerLowest,
        ),
        checkColor: const WidgetStatePropertyAll(onPrimary),
        side: const BorderSide(color: onSurface),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: headlineLg,
        displayMedium: headlineMd,
        headlineSmall: headlineSm,
        titleLarge: headlineSm,
        titleMedium: labelLg,
        titleSmall: labelMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: labelLg,
        labelMedium: labelMd,
        labelSmall: labelSm,
      ),
    );
  }
}
