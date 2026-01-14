import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-modern Dark Theme Palette
  static const Color _primaryColor = Color(0xFF00E5FF); // Neon Cyan
  static const Color _secondaryColor = Color(0xFF7C4DFF); // Deep Purple
  static const Color _backgroundColor = Color(0xFF0A0E21); // Dark Blue-Black
  static const Color _surfaceColor = Color(0xFF1D1E33); // Slightly lighter dark
  static const Color _errorColor = Color(0xFFFF5252);
  
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _surfaceColor,
      error: _errorColor,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: _surfaceColor.withValues(alpha: 0.8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black45,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: _primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(20),
    ),
  );

  // We will force Dark Theme mostly, but providing a Light alternative attempting similar vibes
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2962FF), // Strong Blue
      secondary: Color(0xFF00E5FF),
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
       centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black12,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
       style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
