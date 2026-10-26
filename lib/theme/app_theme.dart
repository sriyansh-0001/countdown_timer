import 'package:flutter/material.dart';

import '../services/timer_service.dart';

/// AppTheme defines the Material 3 visual styling, palettes, typography,
/// and widget themes for both Light and Dark modes.
class AppTheme {
  // Brand Colors
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color backgroundDark = Color(0xFF0B1120); // Deep Navy

  static const Color primaryLight = Color(0xFF1E3A8A); // Blue 900
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50

  // Accent Colors
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentBlue = Color(0xFF0EA5E9); // Sky 500
  static const Color accentTeal = Color(0xFF14B8A6); // Teal 500

  // Status Colors
  static const Color statusReady = Color(0xFF0EA5E9); // Blue
  static const Color statusRunning = Color(0xFF10B981); // Emerald
  static const Color statusPaused = Color(0xFFF59E0B); // Amber
  static const Color statusCompleted = Color(0xFF8B5CF6); // Purple

  // Convenience Aliases
  static Color get darkTrackColor => const Color(0xFF334155);
  static Color get lightTrackColor => const Color(0xFFE2E8F0);
  static Color get darkCardColor => surfaceDark;
  static Color get lightCardColor => surfaceLight;
  static Color get darkSurfaceVariant => const Color(0xFF334155);
  static Color get lightSurfaceVariant => const Color(0xFFF1F5F9);
  static Color get darkPrimary => accentCyan;
  static Color get lightPrimary => primaryLight;
  static Color get darkSecondary => accentBlue;
  static Color get warningAmber => statusPaused;
  static Color get successGreen => statusRunning;
  static Color get dangerRed => const Color(0xFFEF4444);

  static Color statusColor(TimerStatus status, bool isDark) {
    switch (status) {
      case TimerStatus.ready:
        return isDark ? accentCyan : accentBlue;
      case TimerStatus.running:
        return statusRunning;
      case TimerStatus.paused:
        return statusPaused;
      case TimerStatus.completed:
        return statusCompleted;
    }
  }

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryLight,
      onPrimary: Colors.white,
      secondary: accentCyan,
      onSecondary: Colors.white,
      tertiary: accentTeal,
      surface: surfaceLight,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: accentCyan,
      onPrimary: const Color(0xFF0B1120),
      secondary: accentBlue,
      onSecondary: Colors.white,
      tertiary: accentTeal,
      surface: surfaceDark,
      error: const Color(0xFFF87171),
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF334155), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentCyan,
          foregroundColor: const Color(0xFF0B1120),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentCyan, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
