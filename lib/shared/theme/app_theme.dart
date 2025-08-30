import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF1a365d);
  static const Color secondaryColor = Color(0xFF2d5a87);
  static const Color accentColor = Color(0xFF3b82f6);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFffffff);
  static const Color lightSurface = Color(0xFFf8fafc);
  static const Color lightOnPrimary = Color(0xFFffffff);
  static const Color lightOnSurface = Color(0xFF1e293b);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0f172a);
  static const Color darkSurface = Color(0xFF1e293b);
  static const Color darkOnPrimary = Color(0xFFffffff);
  static const Color darkOnSurface = Color(0xFFf1f5f9);
  
  // Error Colors
  static const Color errorColor = Color(0xFFdc2626);
  static const Color successColor = Color(0xFF16a34a);
  static const Color warningColor = Color(0xFFea580c);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightBackground,
        error: errorColor,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnPrimary,
        onSurface: lightOnSurface,
        onError: lightOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightOnPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      scaffoldBackgroundColor: lightBackground,
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: lightOnPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: lightSurface,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFe2e8f0),
        thickness: 1,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkBackground,
        error: errorColor,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnPrimary,
        onSurface: darkOnSurface,
        onError: darkOnPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkOnPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: darkSurface,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
      ),
    );
  }
}
