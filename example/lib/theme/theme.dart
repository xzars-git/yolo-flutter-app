import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';

ThemeData getDefaultTheme() {
  return ThemeData(useMaterial3: false).copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: neutralWhite,
    colorScheme: ColorScheme.light(
      brightness: Brightness.light,
      surface: myColorScheme.surface,
      onSurface: myColorScheme.onSurface,
      surfaceContainerHighest: myColorScheme.surfaceVariant,
      onSurfaceVariant: myColorScheme.onSurfaceVariant,
      outline: myColorScheme.outline,
      primary: myColorScheme.primary,
      onPrimary: myColorScheme.onPrimary,
      secondary: myColorScheme.secondary,
      onSecondary: myColorScheme.onSecondary,
      tertiary: myColorScheme.tertiary,
      onTertiary: myColorScheme.onTertiary,
      error: myColorScheme.error,
      onError: myColorScheme.onError,
      primaryContainer: myColorScheme.primaryContainer,
      onPrimaryContainer: myColorScheme.onPrimaryContainer,
      secondaryContainer: myColorScheme.secondaryContainer,
      onSecondaryContainer: myColorScheme.onSecondaryContainer,
      tertiaryContainer: myColorScheme.tertiaryContainer,
      onTertiaryContainer: myColorScheme.onTertiaryContainer,
      errorContainer: myColorScheme.errorContainer,
      onErrorContainer: myColorScheme.onErrorContainer,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: appbarBackgroundColor,
      elevation: 0,
      titleTextStyle: myTextTheme.titleMedium?.copyWith(color: neutralWhite),
      iconTheme: const IconThemeData(color: neutralWhite),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.blueGrey[900]!,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: Colors.grey,
      unselectedLabelColor: Colors.blueGrey[900]!,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(fontSize: 26, fontWeight: FontWeight.w400, color: gray900),
      displayMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w400, color: gray900),
      displaySmall: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w400, color: gray900),
      headlineLarge: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w400, color: gray900),
      headlineMedium: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w400, color: gray900),
      headlineSmall: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: gray900),
      titleLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500, color: gray900),
      titleMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500, color: gray900),
      titleSmall: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: gray900),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: gray900),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: gray900),
      bodySmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w400, color: gray900),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: gray900),
      labelMedium: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: gray900),
      labelSmall: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w500, color: gray900),
    ),
  );
}
