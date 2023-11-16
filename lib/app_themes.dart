import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightThemes {
  static final theme1 = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFffea00),
      secondary: Color(0xFFff9f1c),
      background: Color(0xFFf7f7f7),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onError: Colors.black,
      error: Colors.red,
      // primaryVariant: Color(0xFFffea00),
      surface: Color.fromARGB(255, 255, 251, 205),
      onSurface: Colors.black,
    ),
    fontFamily: GoogleFonts.josefinSlab().fontFamily,
    fontFamilyFallback: ["Montserrat"],
    textTheme: GoogleFonts.josefinSlabTextTheme().copyWith(
      labelLarge: GoogleFonts.josefinSlab(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        // color: Colors.black,
      ),
    ),
    useMaterial3: true,
  );
}

class DarkThemes {
  static final theme1 = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1b4332),
      secondary: Color(0x00ff9f1c),
      background: Color(0x00081c15),
      onPrimary: Colors.white,
    ),
    useMaterial3: true,
  );
}
