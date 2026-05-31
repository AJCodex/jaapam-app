import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sadhana-inspired devotional theme: cream surface, warm orange primary,
/// serif display headings, soft rounded cards.
class AppTheme {
  AppTheme._();

  static const Color cream = Color(0xFFFAF6EF);
  static const Color primary = Color(0xFFE68C3A);
  static const Color accent = Color(0xFFC2410C);
  static const Color ink = Color(0xFF1F1B16);
  static const Color inkMuted = Color(0xFF7A6F60);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color softBorder = Color(0xFFEDE4D3);
  static const Color amberSoft = Color(0xFFFEF3E2);
  static const Color ringTrack = Color(0xFFF4E4CC);

  static const double radiusCard = 20;
  static const double radiusChip = 12;
  static const double radiusButton = 14;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      tertiary: amberSoft,
      onTertiary: ink,
      error: Color(0xFFB91C1C),
      onError: Colors.white,
      surface: cream,
      onSurface: ink,
      surfaceContainerHighest: surfaceWhite,
      onSurfaceVariant: inkMuted,
      outline: softBorder,
      outlineVariant: softBorder,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF59E0B),
      onPrimary: Colors.black,
      secondary: Color(0xFFFB923C),
      onSecondary: Colors.black,
      tertiary: Color(0xFF2A1F14),
      onTertiary: cream,
      error: Color(0xFFEF4444),
      onError: Colors.black,
      surface: Color(0xFF1B1714),
      onSurface: cream,
      surfaceContainerHighest: Color(0xFF26211C),
      onSurfaceVariant: Color(0xFFB8AC9C),
      outline: Color(0xFF3A332C),
      outlineVariant: Color(0xFF3A332C),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    final body = GoogleFonts.interTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final heading = GoogleFonts.playfairDisplayTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final textTheme = body.copyWith(
      displayLarge: heading.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium:
          heading.displayMedium?.copyWith(fontWeight: FontWeight.w600),
      displaySmall:
          heading.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      headlineLarge:
          heading.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
      headlineMedium:
          heading.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      headlineSmall:
          heading.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: heading.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.tertiary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusChip),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        indicatorColor: scheme.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
