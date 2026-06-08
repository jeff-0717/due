import 'package:flutter/material.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppTokens.background,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.primary,
        secondary: AppTokens.secondary,
        surface: AppTokens.card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppTokens.textPrimary,
        outline: AppTokens.border,
        error: AppTokens.danger,
      ),
      splashColor: AppTokens.primary.withValues(alpha: 0.08),
      highlightColor: AppTokens.primary.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.background,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppTokens.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        focusElevation: 1,
        hoverElevation: 1,
        highlightElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          side: const BorderSide(color: AppTokens.border),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppTokens.pagePadding,
          vertical: 8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.card,
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
          borderSide: const BorderSide(color: AppTokens.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing,
            vertical: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surfaceLow,
        selectedColor: AppTokens.successSoft,
        side: const BorderSide(color: AppTokens.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
        ),
        labelStyle: const TextStyle(
          color: AppTokens.textSecondary,
          fontSize: AppTokens.fontSizeSmall,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppTokens.fontSizeLargeNumber,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTokens.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppTokens.fontSizeBodyLarge,
          fontWeight: FontWeight.w700,
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
          height: 1.45,
        ),
        labelSmall: TextStyle(
          fontSize: AppTokens.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: AppTokens.textMuted,
        ),
      ),
    );
  }
}
