import 'package:flutter/material.dart';

class AppColorPalette {
  final Color primary;
  final Color accent;
  final Color appBar;
  final Color text;
  final Color background;
  final Color bottomNavBackground;
  final Color bottomNavSelected;
  final Color bottomNavUnselected;

  const AppColorPalette({
    required this.primary,
    required this.accent,
    required this.appBar,
    required this.text,
    required this.background,
    required this.bottomNavBackground,
    required this.bottomNavSelected,
    required this.bottomNavUnselected,
  });
}

class AppTheme {
  final String name;
  final AppColorPalette light;
  final AppColorPalette dark;

  const AppTheme({
    required this.name,
    required this.light,
    required this.dark,
  });
}


class AppColors {
  static const AppTheme pinkTheme = AppTheme(
    name: "Pink",
    light: AppColorPalette(
      primary: Colors.pink,
      accent: Colors.pink,
      appBar: Colors.pink,
      text: Colors.black87,
      background: Colors.white,
      bottomNavBackground: Colors.white,
      bottomNavSelected: Colors.pink,
      bottomNavUnselected: Colors.grey,
    ),
    dark: AppColorPalette(
      primary: Colors.pink,
      accent: Colors.pinkAccent,
      appBar: Colors.grey,
      text: Colors.white70,
      background: Color(0xFF2A2A2A),
      bottomNavBackground: Color(0xFF1E1E1E),
      bottomNavSelected: Colors.pinkAccent,
      bottomNavUnselected: Colors.grey,
    ),
  );

  static const AppTheme blueTheme = AppTheme(
    name: "Blue",
    light: AppColorPalette(
      primary: Colors.blue,
      accent: Colors.blueAccent,
      appBar: Colors.blue,
      text: Colors.black87,
      background: Colors.white,
      bottomNavBackground: Colors.white,
      bottomNavSelected: Colors.blue,
      bottomNavUnselected: Colors.grey,
    ),
    dark: AppColorPalette(
      primary: Colors.lightBlueAccent,
      accent: Colors.lightBlue,
      appBar: Colors.black,
      text: Colors.white70,
      background: Color(0xFF2A2A2A),
      bottomNavBackground: Color(0xFF1E1E1E),
      bottomNavSelected: Colors.lightBlueAccent,
      bottomNavUnselected: Colors.grey,
    ),
  );

  static const AppTheme purpleTheme = AppTheme(
    name: "Purple",
    light: AppColorPalette(
      primary: Colors.deepPurple,
      accent: Colors.deepPurple,
      appBar: Colors.deepPurple,
      text: Colors.black87,
      background: Colors.white,
      bottomNavBackground: Colors.white,
      bottomNavSelected: Colors.deepPurple,
      bottomNavUnselected: Colors.grey,
    ),
    dark: AppColorPalette(
      primary: Colors.deepPurpleAccent,
      accent: Colors.purpleAccent,
      appBar: Colors.black,
      text: Colors.white70,
      background: Color(0xFF2A2A2A),
      bottomNavBackground: Color(0xFF1E1E1E),
      bottomNavSelected: Colors.deepPurpleAccent,
      bottomNavUnselected: Colors.grey,
    ),
  );

  static List<AppTheme> allThemes = [
    pinkTheme,
    blueTheme,
    purpleTheme,
  ];
}
