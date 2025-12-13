import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF5F5F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1D1D1F);
  static const Color textSub = Color(0xFF86868B);
  static const Color blue = Color(0xFF0071E3);
  static const Color red = Color(0xFFFF3B30);
  static const Color green = Color(0xFF34C759);
  static const Color orange = Color(0xFFFF9500);
  static const Color purple = Color(0xFFAF52DE);

  static TextStyle get timerFont => GoogleFonts.ibmPlexMono(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      );

  static TextStyle get titleLarge => GoogleFonts.vazirmatn(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: textMain,
        letterSpacing: -1,
      );

  static TextStyle get body =>
      GoogleFonts.vazirmatn(fontSize: 16, color: textMain, height: 1.5);

  static BorderRadius radius = BorderRadius.circular(24);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
