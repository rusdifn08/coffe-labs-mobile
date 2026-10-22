import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Coffee inspired palette
  static const Color primaryBrown = Color(0xFF6B4423); // Espresso
  static const Color lightBrown = Color(0xFF9A7B4F);   // Latte
  static const Color accentAmber = Color(0xFFECA400);  // Warm Accent
  static const Color accentGold = Color(0xFFD4AF37);   // Gold Accent
  static const Color bgCream = Color(0xFFF9F6F0);      // Soft Background
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF332B25);     // Dark Brown/Black text
  static const Color textMuted = Color(0xFF8F857D);    // Muted text
  static const Color dividerColor = Color(0xFFE8DFD8); // Soft divider
  static const Color borderWarm = Color(0xFFE8DFD8);   // Warm border

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBrown,
      scaffoldBackgroundColor: bgCream,
      colorScheme: const ColorScheme.light(
        primary: primaryBrown,
        secondary: accentAmber,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: textDark),
        bodyMedium: GoogleFonts.poppins(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgCream,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryBrown,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: primaryBrown.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentAmber,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
