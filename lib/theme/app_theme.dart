import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // FRESHTRACK BRAND COLORS
  // ==========================================

  static const Color forest = Color(0xFF173E30);
  static const Color sage = Color(0xFFDCE9D6);
  static const Color ivory = Color(0xFFF7F6F0);
  static const Color lime = Color(0xFFDDE8C6);

  // Text and supporting colors
  static const Color text = Color(0xFF203C30);
  static const Color muted = Color(0xFF758076);
  static const Color white = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4E9DF);

  // ==========================================
  // SHARED DESIGN VALUES
  // ==========================================

  static const double cardRadius = 24.0;
  static const double buttonRadius = 18.0;

  // ==========================================
  // APPLICATION THEME
  // ==========================================

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      // Background color
      scaffoldBackgroundColor: ivory,

      // Application color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: forest,
        primary: forest,
        surface: ivory,
      ),

      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: ivory,
        foregroundColor: forest,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
          color: text,
        ),

        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: text,
        ),

        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: text,
        ),

        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: text),

        bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: muted),

        bodySmall: TextStyle(fontSize: 12, color: muted),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forest,
          foregroundColor: white,
          elevation: 0,
          minimumSize: const Size.fromHeight(58),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),

          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forest,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: border),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: forest),
      ),

      // Card styling
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: border),
        ),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        indicatorColor: sage,
        height: 72,
        elevation: 0,
      ),

      // Floating SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: forest,
        contentTextStyle: const TextStyle(color: white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
