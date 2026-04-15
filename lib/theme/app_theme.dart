import 'package:flutter/material.dart';

class AppTheme {
  static const Color cream = Color(0xFFFFF7EC);
  static const Color blush = Color(0xFFFFD8E6);
  static const Color mint = Color(0xFFD7F3E3);
  static const Color sky = Color(0xFFD8EBFF);
  static const Color peach = Color(0xFFFFE7CE);
  static const Color cocoa = Color(0xFF6F5C52);

  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: blush,
        brightness: Brightness.light,
        surface: cream,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBF7),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: cocoa,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: cocoa,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: cocoa,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF665D57),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Color(0xFF786E67),
        ),
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFF3D9E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFF3AFC7), width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: blush,
          foregroundColor: cocoa,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
