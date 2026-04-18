import 'package:flutter/material.dart';

class AppTheme {
  static const Color paper = Color(0xFFFFFCF8);
  static const Color ivory = Color(0xFFFFF7F1);
  static const Color petal = Color(0xFFF8E6EA);
  static const Color mist = Color(0xFFEAF1F7);
  static const Color sage = Color(0xFFE4F0E8);
  static const Color apricot = Color(0xFFF8E8D6);
  static const Color cream = ivory;
  static const Color blush = petal;
  static const Color mint = sage;
  static const Color sky = mist;
  static const Color peach = apricot;
  static const Color line = Color(0xFFEADFD8);
  static const Color cocoa = Color(0xFF5F534E);
  static const Color body = Color(0xFF736761);
  static const Color muted = Color(0xFF988B84);
  static const Color accent = Color(0xFFA7647D);

  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: petal,
        brightness: Brightness.light,
        primary: accent,
        surface: ivory,
      ),
      scaffoldBackgroundColor: paper,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: cocoa,
          letterSpacing: -0.8,
          fontFamily: 'Georgia',
          fontFamilyFallback: ['Times New Roman', 'Noto Serif TC', 'serif'],
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: cocoa,
          letterSpacing: -0.4,
          fontFamily: 'Georgia',
          fontFamilyFallback: ['Times New Roman', 'Noto Serif TC', 'serif'],
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: cocoa,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: cocoa,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.65,
          color: body,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: body,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: muted,
        ),
      ),
    );

    final scheme = base.colorScheme;
    return base.copyWith(
      colorScheme: scheme.copyWith(
        primary: accent,
        secondary: const Color(0xFFC69BAB),
        surface: ivory,
      ),
      dividerColor: line,
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cocoa,
          side: const BorderSide(color: Color(0xFFBDAFA7)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: body),
        hintStyle: const TextStyle(color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFD4A4B3), width: 1.2),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cocoa.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
