import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color backgroundColor = Color(0xFF121212);
  static const Color darkNavy = Color(0xFF1A1A2E);
  static const Color primaryColor = Color(0xFFFF4081); // Soft pink
  static const Color secondaryColor = Color(0xFF9C27B0); // Purple
  static const Color accentColor = Color(0xFF26A69A); // Teal
  static const Color lightYellow = Color(0xFFFFF176);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2A2A2A);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.rubik(color: textHint, fontSize: 16),
        prefixIconColor: textSecondary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryColor.withOpacity(0.2),
        disabledColor: Colors.grey.shade800,
        labelStyle: GoogleFonts.rubik(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: Colors.grey.shade700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
    );
  }

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.rubik(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get labelLarge => GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get cardTitle => GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    shadows: [
      const Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 1)),
    ],
  );
}
