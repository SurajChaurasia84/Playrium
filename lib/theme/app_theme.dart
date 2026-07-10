import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Theme Color Constants
  static const Color primaryColor = Color(0xFF6C5CE7);     // Neon Violet
  static const Color secondaryColor = Color(0xFF00D1FF);   // Neon Cyan
  static const Color accentColor = Color(0xFFFFD166);      // Gaming Gold
  
  static const Color darkBgColor = Color(0xFF0F1117);      // Premium Dark Background
  static const Color darkSurfaceColor = Color(0xFF1E2230); // Glassy surface dark
  static const Color darkCardColor = Color(0xFF161A26);
  
  static const Color lightBgColor = Color(0xFFF7F8FC);     // Light Background
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFEDF0F7);

  // Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBgColor,
      cardColor: lightCardColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightSurfaceColor,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        bodyMedium: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
    );
  }

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBgColor,
      cardColor: darkCardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkSurfaceColor,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        bodyLarge: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        bodyMedium: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),
    );
  }
}
