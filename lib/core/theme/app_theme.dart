import 'package:flutter/material.dart';

/// AquaSoothe Theme matching light mint and deep bedtime dark modes
class AppTheme {
  // Light Palette Colors
  static const Color backgroundMint = Color(0xFFEFF8F6);
  static const Color primaryDeepTeal = Color(0xFF0C4648);
  static const Color textSubtleTeal = Color(0xFF5B787A);
  static const Color cardLightMint = Color(0xFFE1F2F0);
  static const Color cardMediumTeal = Color(0xFFBDE4E1);
  static const Color cardSlateTeal = Color(0xFFC9DFDD);
  static const Color cardPeach = Color(0xFFF7BD9E);
  static const Color cardTaupe = Color(0xFFCFC5B7);
  static const Color accentPeach = Color(0xFFF8AB80);
  static const Color buttonBeige = Color(0xFFEFE6D8);
  static const Color textDarkBrown = Color(0xFF4D2411);
  static const Color borderSubtle = Color(0xFFDAEAE7);

  // Bedtime Dark Mode Palette Colors
  static const Color darkBackground = Color(0xFF0B191C);
  static const Color darkCardBg = Color(0xFF13272C);
  static const Color darkPrimaryTeal = Color(0xFF70D6CE);
  static const Color darkTextPrimary = Color(0xFFE3F5F3);
  static const Color darkTextSubtle = Color(0xFF88ACAA);
  static const Color darkBorderSubtle = Color(0xFF1E3A40);

  static ThemeData lightTheme(double textScaleFactor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundMint,
      colorScheme: ColorScheme.light(
        primary: primaryDeepTeal,
        onPrimary: Colors.white,
        secondary: accentPeach,
        onSecondary: textDarkBrown,
        surface: cardLightMint,
        onSurface: primaryDeepTeal,
      ),
      fontFamily: 'sans-serif',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 30 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryDeepTeal,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'serif',
          fontSize: 24 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryDeepTeal,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 22 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryDeepTeal,
        ),
        titleMedium: TextStyle(
          fontSize: 18 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: primaryDeepTeal,
        ),
        bodyLarge: TextStyle(
          fontSize: 17 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: textSubtleTeal,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15 * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: textSubtleTeal,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundMint,
        foregroundColor: primaryDeepTeal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryDeepTeal,
        ),
        iconTheme: IconThemeData(size: 26, color: primaryDeepTeal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeepTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: 18 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLightMint,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryDeepTeal,
        unselectedItemColor: textSubtleTeal,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryDeepTeal),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSubtleTeal),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData darkTheme(double textScaleFactor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryTeal,
        onPrimary: darkBackground,
        secondary: accentPeach,
        onSecondary: textDarkBrown,
        surface: darkCardBg,
        onSurface: darkTextPrimary,
      ),
      fontFamily: 'sans-serif',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 30 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'serif',
          fontSize: 24 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'serif',
          fontSize: 22 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17 * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: darkTextSubtle,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15 * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: darkTextSubtle,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        iconTheme: IconThemeData(size: 26, color: darkTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryTeal,
          foregroundColor: darkBackground,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontSize: 18 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardBg,
        selectedItemColor: darkPrimaryTeal,
        unselectedItemColor: darkTextSubtle,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkPrimaryTeal),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: darkTextSubtle),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
