import 'package:flutter/cupertino.dart';

/// Color tokens for the Liquid Glass design language. Every surface is a
/// translucent layer over [canvasGradient], so colors here are chosen for
/// how they read at ~10-20% opacity, not as flat fills.
class AppColors {
  const AppColors._();

  static const Color canvasTop = Color(0xFFEFF1F6);
  static const Color canvasBottom = Color(0xFFDCE2F0);

  static const List<Color> canvasGradient = [canvasTop, canvasBottom];

  static const Color ink = Color(0xFF1C1C1E);
  static const Color inkSubdued = Color(0xFF6E6E76);

  static const Color glassTint = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFFFFFFFF);

  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color accentGreen = Color(0xFF32D74B);
  static const Color accentOrange = Color(0xFFFF9F0A);
  static const Color accentPurple = Color(0xFFBF5AF2);
  static const Color accentRed = Color(0xFFFF453A);

  static Color categoryColor(String category) {
    switch (category) {
      case 'کاری':
        return accentBlue;
      case 'خرید':
        return accentOrange;
      case 'مطالعه':
        return accentPurple;
      default:
        return accentGreen;
    }
  }

  static const Color focusCanvas = Color(0xFF060608);
}
