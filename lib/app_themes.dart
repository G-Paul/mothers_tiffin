import 'package:flutter/material.dart';

class LightThemes {
  static final theme1 = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6a994e)).copyWith(),
    useMaterial3: true,
  );
}

class DarkThemes {
  static final theme1 = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1b4332),
      secondary: Color(0xff9f1c),
      background: Color(0x081c15),
      onPrimary: Colors.white,
    ),
    useMaterial3: true,
  );
}
