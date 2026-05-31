import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Devotional + minimalistic theme.
/// Saffron primary, muted violet accent, warm sandalwood surfaces.
/// Material 3, generous spacing, rounded corners, no gradients.
class AppTheme {
  AppTheme._();

  // Brand tokens
  static const Color saffron = Color(0xFFB45309); // warm amber-saffron
  static const Color violet = Color(0xFF7C3AED);  // muted spiritual violet
  static const Color sandalwood = Color(0xFFFAF7F2); // warm off-white surface
  static const Color ink = Color(0xFF1C1917);     // warm near-black text
  static const Color inkMuted = Color(0xFF78716C);
  static const Color success = Color(0xFF15803D);

  static const double radius = 12;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: saffron,
      brightness: Brightness.light,
      primary: saffron,
      secondary: violet,
      surface: sandalwood,
      onSurface: ink,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: saffron,
      brightness: Brightness.dark,
      primary: const Color(0xFFF59E0B),
      secondary: const Color(0xFFA78BFA),
      surface: const Color(0xFF1C1917),
      onSurface: sandalwood,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final headingFont = GoogleFonts.tiroDevanagariHindi(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme.copyWith(
        displayLarge: headingFont.copyWith(fontSize: 48),
        displayMedium: headingFont.copyWith(fontSize: 36),
        displaySmall: headingFont.copyWith(fontSize: 28),
        headlineLarge: headingFont.copyWith(fontSize: 24),
        headlineMedium: headingFont.copyWith(fontSize: 20),
        headlineSmall: headingFont.copyWith(fontSize: 18),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont.copyWith(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
