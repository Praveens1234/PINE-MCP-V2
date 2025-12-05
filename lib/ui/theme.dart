import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0D1117), // Deep dark background
    primaryColor: Color(0xFF2962FF), // TradingView Blue
    fontFamily: 'GoogleFonts.roboto',
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF2962FF),
      secondary: Color(0xFF00E676), // Neon Green
      surface: Color(0xFF161B22),
      background: Color(0xFF0D1117),
      error: Color(0xFFFF5252),
    ),
    useMaterial3: true,
  );
  
  static const glassStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w300,
  );
}
