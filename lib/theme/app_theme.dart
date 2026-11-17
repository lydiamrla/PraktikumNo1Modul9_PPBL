import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgTop = Color(0xFF7B1FA2); // Ungu cerah atas
  static const Color bgMiddle = Color(0xFF311042); // Ungu gelap tengah
  static const Color bgBottom = Color(0xFF14071E); // Gelap pekat bawah
  static const Color accentPurple = Color(0xFFAB47BC);
  static const Color cardGlass = Color(0x26FFFFFF);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMiddle, bgBottom],
    stops: [0.0, 0.45, 1.0],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBottom,
      primaryColor: bgTop,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: Color(0xFFE040FB),
        surface: Color(0xFF240B36),
      ),
    );
  }
}