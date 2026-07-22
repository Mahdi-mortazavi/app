import 'package:flutter/cupertino.dart';

/// Static, appearance-independent tokens: the accent palette (identical in
/// both appearances by design — accents are semantic, not decorative) and
/// the always-dark immersive Focus canvas.
class AppColors {
  const AppColors._();

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

  /// The Focus screen is an immersive, always-dark mode regardless of
  /// appearance — like a full-screen player.
  static const Color focusCanvas = Color(0xFF060608);
}

/// The semantic appearance scheme — every appearance-dependent color in the
/// app resolves through here, giving Nava a true light and dark rendition
/// (smoked glass in the dark, not just an inverted background).
class NavaColors {
  const NavaColors({
    required this.brightness,
    required this.canvasTop,
    required this.canvasBottom,
    required this.ink,
    required this.inkSubdued,
    required this.surface,
    required this.surfaceBorder,
    required this.sheet,
    required this.glassTint,
    required this.glassSpecular,
    required this.fill,
  });

  final Brightness brightness;

  /// Screen background gradient endpoints.
  final Color canvasTop;
  final Color canvasBottom;

  /// Primary / secondary label colors.
  final Color ink;
  final Color inkSubdued;

  /// Solid content card fill + its hairline border (content is NOT glass).
  final Color surface;
  final Color surfaceBorder;

  /// Opaque-ish sheet/dialog background.
  final Color sheet;

  /// Chrome glass tint and its specular (light-catching) edge.
  final Color glassTint;
  final Color glassSpecular;

  /// Subtle inset fill (e.g. form sub-rows).
  final Color fill;

  bool get isDark => brightness == Brightness.dark;

  static const light = NavaColors(
    brightness: Brightness.light,
    canvasTop: Color(0xFFEFF1F6),
    canvasBottom: Color(0xFFDCE2F0),
    ink: Color(0xFF1C1C1E),
    inkSubdued: Color(0xFF6E6E76),
    surface: Color(0xFFFFFFFF),
    surfaceBorder: Color(0x0F000000),
    sheet: Color(0xFFF7F7FA),
    glassTint: Color(0xFFFFFFFF),
    glassSpecular: Color(0xFFFFFFFF),
    fill: Color(0x14787880),
  );

  static const dark = NavaColors(
    brightness: Brightness.dark,
    canvasTop: Color(0xFF17181D),
    canvasBottom: Color(0xFF0D0E12),
    ink: Color(0xFFF2F2F7),
    inkSubdued: Color(0xFF9B9BA3),
    surface: Color(0xFF1F2027),
    surfaceBorder: Color(0x14FFFFFF),
    sheet: Color(0xFF1C1D23),
    glassTint: Color(0xFF3A3B43),
    glassSpecular: Color(0xFFFFFFFF),
    fill: Color(0x29787880),
  );

  static NavaColors of(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? dark
          : light;
}
