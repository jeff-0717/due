import 'package:flutter/material.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppTokens.background,
      colorScheme: ColorScheme.light(
        primary: AppTokens.primary,
        secondary: AppTokens.accent,
        surface: AppTokens.card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppTokens.textPrimary,
        outline: AppTokens.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.background,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          side: const BorderSide(color: AppTokens.border),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing,
          vertical: 8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          borderSide: const BorderSide(color: AppTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          borderSide: const BorderSide(color: AppTokens.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppTokens.spacing),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing,
            vertical: 14,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppTokens.fontSizeLargeNumber,
          fontWeight: FontWeight.w700,
          color: AppTokens.textPrimary,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTokens.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTokens.fontSizeBody,
          fontWeight: FontWeight.w500,
          color: AppTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTokens.fontSizeBody,
          fontWeight: FontWeight.normal,
          color: AppTokens.textSecondary,
        ),
      ),
    );
  }
}
