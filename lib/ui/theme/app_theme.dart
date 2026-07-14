import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF64B5F6),
      secondary: Color(0xFF81D4FA),
      surface: Color(0xFF1E1E1E),
      surfaceContainerHighest: Color(0xFF2C2C2C),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFF9E9E9E),
      error: Color(0xFFEF5350),
      errorContainer: Color(0xFFD32F2F),
      onErrorContainer: Color(0xFFFFCDD2),
      outline: Color(0xFF616161),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE0E0E0),
        elevation: 0,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFE0E0E0),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
        bodySmall: TextStyle(color: Color(0xFF9E9E9E)),
        titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
        titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
        titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}