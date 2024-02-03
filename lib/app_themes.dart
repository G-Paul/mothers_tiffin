import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightThemes {
  static final theme1 = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromRGBO(255, 179, 43, 1),
      secondary: Color.fromARGB(255, 245, 198, 60),
      background: Color.fromARGB(255, 233, 238, 224),
      onPrimary: Color.fromARGB(195, 0, 0, 0),
      onSecondary: Color.fromARGB(65, 0, 0, 0),
      onBackground: Color.fromARGB(255, 0, 0, 0),
      onError: Color.fromARGB(255, 255, 255, 255),
      error: Color.fromARGB(255, 255, 0, 0),
      // primaryVariant: Color.fromARGB(255, 255, 159, 28),
      surface: Color.fromARGB(255, 252, 250, 236),
      onSurface: Color.fromARGB(255, 0, 0, 0),
    ),
    fontFamily: GoogleFonts.josefinSlab().fontFamily,
    fontFamilyFallback: const ["Montserrat"],
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
      primary: Color.fromARGB(255, 27, 67, 50),
      secondary: Color.fromARGB(255, 255, 159, 28),
      background: Color.fromARGB(255, 8, 28, 21),
      onPrimary: Color.fromARGB(255, 255, 255, 255),
    ),
    useMaterial3: true,
  );
}
