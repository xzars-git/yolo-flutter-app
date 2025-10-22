import 'package:flutter/material.dart';

/// App-wide theme configuration
/// Centralized theme untuk consistency across app
class AppTheme {
  // Private constructor
  AppTheme._();

  // ============================================================
  // COLOR PALETTE
  // ============================================================
  
  // Primary Colors
  static const Color primaryBlue = Color(0xff1E88E5);
  static const Color primaryYellow = Color(0xffFFD026);
  static const Color primaryGreen = Color(0xff16A75C);
  
  // Gray Palette
  static const Color gray50 = Color(0xffFAFAFA);
  static const Color gray100 = Color(0xffF5F5F5);
  static const Color gray200 = Color(0xffEEEEEE);
  static const Color gray300 = Color(0xffE0E0E0);
  static const Color gray400 = Color(0xffBDBDBD);
  static const Color gray500 = Color(0xff9E9E9E);
  static const Color gray600 = Color(0xff757575);
  static const Color gray700 = Color(0xff616161);
  static const Color gray800 = Color(0xff424242);
  static const Color gray900 = Color(0xff212121);
  
  // Blue Palette
  static const Color blue50 = Color(0xffE3F2FD);
  static const Color blue100 = Color(0xffBBDEFB);
  static const Color blue200 = Color(0xff90CAF9);
  static const Color blue300 = Color(0xff64B5F6);
  static const Color blue400 = Color(0xff42A5F5);
  static const Color blue500 = Color(0xff2196F3);
  static const Color blue600 = Color(0xff1E88E5);
  static const Color blue700 = Color(0xff1976D2);
  static const Color blue800 = Color(0xff1565C0);
  static const Color blue900 = Color(0xff0D47A1);
  
  // BlueGray Palette
  static const Color blueGray50 = Color(0xffE3E7ED);
  static const Color blueGray100 = Color(0xffB9C3D3);
  static const Color blueGray200 = Color(0xff8D9DB5);
  static const Color blueGray300 = Color(0xff627798);
  static const Color blueGray400 = Color(0xff415C84);
  static const Color blueGray500 = Color(0xff1A4373);
  static const Color blueGray600 = Color(0xff133C6B);
  static const Color blueGray700 = Color(0xff083461);
  static const Color blueGray800 = Color(0xff022B55);
  static const Color blueGray900 = Color(0xff001B3D);
  
  // Green Palette
  static const Color green50 = Color(0xffE6F6EC);
  static const Color green100 = Color(0xffC3E9D0);
  static const Color green200 = Color(0xff9BDBB3);
  static const Color green300 = Color(0xff70CD94);
  static const Color green400 = Color(0xff4DC27E);
  static const Color green500 = Color(0xff1FB767);
  static const Color green600 = Color(0xff16A75C);
  static const Color green700 = Color(0xff069550);
  static const Color green800 = Color(0xff008444);
  static const Color green900 = Color(0xff006430);
  
  // Red Palette
  static const Color red50 = Color(0xffFFEBEE);
  static const Color red100 = Color(0xffFFCDD2);
  static const Color red200 = Color(0xffEF9A9A);
  static const Color red300 = Color(0xffE57373);
  static const Color red400 = Color(0xffEF5350);
  static const Color red500 = Color(0xffF44336);
  static const Color red600 = Color(0xffE53935);
  static const Color red700 = Color(0xffD32F2F);
  static const Color red800 = Color(0xffC62828);
  static const Color red900 = Color(0xffB71B1C);
  
  // Yellow Palette
  static const Color yellow50 = Color(0xffFFF9E1);
  static const Color yellow100 = Color(0xffFFEEB4);
  static const Color yellow200 = Color(0xffFFE483);
  static const Color yellow300 = Color(0xffFFDA4F);
  static const Color yellow400 = Color(0xffFFD026);
  static const Color yellow500 = Color(0xffFFC800);
  static const Color yellow600 = Color(0xffFFB900);
  static const Color yellow700 = Color(0xffFFA600);
  static const Color yellow800 = Color(0xffFF9500);
  static const Color yellow900 = Color(0xffFF7500);
  
  // Purple Palette
  static const Color purple50 = Color(0xffF3E5F5);
  static const Color purple100 = Color(0xffE1BEE7);
  static const Color purple200 = Color(0xffCE93D8);
  static const Color purple300 = Color(0xffBA68C8);
  static const Color purple400 = Color(0xffAB47BC);
  static const Color purple500 = Color(0xff9B27B0);
  static const Color purple600 = Color(0xff8D24AA);
  static const Color purple700 = Color(0xff7A1FA2);
  static const Color purple800 = Color(0xff691B9A);
  static const Color purple900 = Color(0xff49148C);
  
  // Neutral Colors
  static const Color neutralWhite = Color(0xffFFFFFF);
  static const Color neutralBlack = Color(0xff000000);
  
  // Status Colors
  static const Color successColor = green600;
  static const Color errorColor = red600;
  static const Color warningColor = yellow600;
  static const Color infoColor = blue600;
  
  // ============================================================
  // TEXT THEME
  // ============================================================
  
  static TextTheme get textTheme {
    return const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: gray900,
        fontFamily: 'Roboto',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: gray900,
        fontFamily: 'Roboto',
      ),
    );
  }
  
  // ============================================================
  // LIGHT THEME
  // ============================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false, // Use Material 2 for consistency
      brightness: Brightness.light,
      
      // Primary colors
      primaryColor: blue900,
      scaffoldBackgroundColor: neutralWhite,
      
      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: blue900,
        secondary: primaryGreen,
        error: red600,
        surface: neutralWhite,
        onPrimary: neutralWhite,
        onSecondary: neutralWhite,
        onError: neutralWhite,
        onSurface: gray900,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: blue900,
        foregroundColor: neutralWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: neutralWhite,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: neutralWhite,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: neutralWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blue900,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: blue900,
          side: const BorderSide(color: blue900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: blue900, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neutralWhite,
        selectedItemColor: blue900,
        unselectedItemColor: gray500,
        elevation: 8,
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: neutralWhite,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: gray300,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: textTheme,
    );
  }
  
  // ============================================================
  // DARK THEME
  // ============================================================
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF212332),
      
      appBarTheme: const AppBarTheme(
        elevation: 0.6,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
      ),
      
      textTheme: const TextTheme(
        titleSmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        titleMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        titleLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        bodySmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
      ),
    );
  }
  
  // ============================================================
  // CONSTANTS
  // ============================================================
  
  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusXS = 6.0;
  static const double radiusS = 12.0;
  static const double radiusM = 20.0;
  static const double radiusL = 30.0;
  static const double radiusXL = 40.0;
  
  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;
}
