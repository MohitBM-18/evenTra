// Copyright (c) 2026 evenTra. All rights reserved.
// Christ University Venue Booking Platform.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Enterprise design system for evenTra.
///
/// Inspired by Microsoft Teams, Linear, Notion, and Google Workspace.
/// No gradients, glassmorphism, or neon effects.
class AppTheme {
  AppTheme._();

  // ─── LIGHT MODE PALETTE ──────────────────────────────────────────────
  static const Color _lightPrimary = Color(0xFF4F46E5); // Indigo-600
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF1A1A2E);
  static const Color _lightTextSecondary = Color(0xFF64748B); // Slate-500
  static const Color _lightBorder = Color(0xFFE2E8F0); // Slate-200
  static const Color _lightDivider = Color(0xFFE2E8F0);

  // ─── DARK MODE PALETTE ───────────────────────────────────────────────
  static const Color _darkPrimary = Color(0xFF818CF8); // Indigo-400
  static const Color _darkOnPrimary = Color(0xFF1E1B4B);
  static const Color _darkBackground = Color(0xFF0F172A); // Slate-900
  static const Color _darkSurface = Color(0xFF1E293B); // Slate-800
  static const Color _darkText = Color(0xFFF1F5F9); // Slate-100
  static const Color _darkTextSecondary = Color(0xFF94A3B8); // Slate-400
  static const Color _darkBorder = Color(0xFF334155); // Slate-700
  static const Color _darkDivider = Color(0xFF334155);

  // ─── SEMANTIC COLORS (shared) ────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── LAYOUT CONSTANTS ────────────────────────────────────────────────
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // ─── BACKWARD COMPAT (old code references) ───────────────────────────
  // These are kept so existing references don't break during migration.
  static const Color primaryPurple = _lightPrimary;
  static const Color primaryCyan = info;
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentAmber = warning;
  static const Color pending = warning;
  static const Color lightPrimary = _lightPrimary;
  static const Color lightSecondary = Color(0xFF6366F1);
  static const Color lightSuccess = success;
  static const Color lightWarning = warning;
  static const Color lightError = error;
  static const Color lightText = _lightText;
  static const Color darkPrimary = _darkPrimary;

  // Kept for compat — but returns solid color, no gradient.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_lightPrimary, _lightPrimary],
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [_lightPrimary, _lightPrimary],
  );

  static const double defaultRadius = radiusMd;
  static const double largeRadius = radiusLg;

  // ─── HELPERS ─────────────────────────────────────────────────────────
  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkText : _lightText;

  static Color secondaryTextColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkTextSecondary
          : _lightTextSecondary;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkSurface
          : _lightSurface;

  static Color bgColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkBorder
          : _lightBorder;

  static Color primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkPrimary
          : _lightPrimary;

  /// Standard card decoration — no glass, no blur.
  static BoxDecoration cardDecoration(BuildContext context, {double radius = radiusMd}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? _darkSurface : _lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: isDark ? _darkBorder : _lightBorder, width: 1),
    );
  }

  /// @deprecated Use [cardDecoration] instead.
  static BoxDecoration glassDecoration({BuildContext? context, double radius = radiusMd, bool? isDark}) {
    final dark = isDark ?? (context != null ? Theme.of(context).brightness == Brightness.dark : false);
    return BoxDecoration(
      color: dark ? _darkSurface : _lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: dark ? _darkBorder : _lightBorder, width: 1),
    );
  }

  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // ─── TYPOGRAPHY ──────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color textColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700, fontSize: 32),
      displayMedium: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700, fontSize: 28),
      displaySmall: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w700, fontSize: 24),
      headlineLarge: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 22),
      headlineMedium: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 20),
      headlineSmall: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
      titleMedium: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
      titleSmall: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w500, fontSize: 13),
      bodyLarge: GoogleFonts.inter(color: textColor, fontSize: 15),
      bodyMedium: GoogleFonts.inter(color: textColor, fontSize: 14),
      bodySmall: GoogleFonts.inter(color: secondaryColor, fontSize: 12),
      labelLarge: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium: GoogleFonts.inter(color: secondaryColor, fontWeight: FontWeight.w500, fontSize: 12),
      labelSmall: GoogleFonts.inter(color: secondaryColor, fontWeight: FontWeight.w500, fontSize: 11),
    );
  }

  // ─── LIGHT THEME ─────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      primaryColor: _lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        secondary: Color(0xFF6366F1),
        surface: _lightSurface,
        error: error,
        outline: _lightBorder,
      ),
      textTheme: _buildTextTheme(_lightText, _lightTextSecondary),
      dividerColor: _lightDivider,
      dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _lightText, size: 20),
        titleTextStyle: GoogleFonts.inter(
          color: _lightText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: _lightTextSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: _lightTextSecondary, fontSize: 14),
        errorStyle: GoogleFonts.inter(color: error, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightText,
          side: const BorderSide(color: _lightBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: _lightBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightBackground,
        side: const BorderSide(color: _lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _lightText),
        selectedColor: _lightPrimary.withOpacity(0.1),
        checkmarkColor: _lightPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _lightPrimary,
        unselectedLabelColor: _lightTextSecondary,
        indicatorColor: _lightPrimary,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
        dividerColor: _lightDivider,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: GoogleFonts.inter(color: _lightText, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: GoogleFonts.inter(color: _lightTextSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightText,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
    );
  }

  // ─── DARK THEME ──────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      primaryColor: _darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        secondary: Color(0xFFA5B4FC),
        surface: _darkSurface,
        error: Color(0xFFF87171),
        outline: _darkBorder,
      ),
      textTheme: _buildTextTheme(_darkText, _darkTextSecondary),
      dividerColor: _darkDivider,
      dividerTheme: const DividerThemeData(color: _darkDivider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _darkText, size: 20),
        titleTextStyle: GoogleFonts.inter(
          color: _darkText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: _darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: _darkTextSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: _darkTextSecondary, fontSize: 14),
        errorStyle: GoogleFonts.inter(color: Colors.red[400], fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkText,
          side: const BorderSide(color: _darkBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: _darkBorder),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkBackground,
        side: const BorderSide(color: _darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: _darkText),
        selectedColor: _darkPrimary.withOpacity(0.15),
        checkmarkColor: _darkPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _darkPrimary,
        unselectedLabelColor: _darkTextSecondary,
        indicatorColor: _darkPrimary,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
        dividerColor: _darkDivider,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: GoogleFonts.inter(color: _darkText, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: GoogleFonts.inter(color: _darkTextSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkText,
        contentTextStyle: GoogleFonts.inter(color: _darkBackground, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
    );
  }
}
