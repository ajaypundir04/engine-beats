import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color cardBackground = Color(0xFF1A2230);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentRed = Color(0xFFFF3D00);
  static const Color textMuted = Color(0xFF8899A6);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentAmber,
      error: accentRed,
      surface: cardBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
