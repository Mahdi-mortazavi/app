import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens. Farsi copy uses Vazirmatn; the timer display uses a
/// monospaced face so digits don't reflow the layout as they change.
class AppTypography {
  const AppTypography._();

  static TextStyle get largeTitle => GoogleFonts.vazirmatn(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        letterSpacing: -0.8,
      );

  static TextStyle get title => GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.inkSubdued,
      );

  static TextStyle get timer => GoogleFonts.ibmPlexMono(
        fontSize: 68,
        fontWeight: FontWeight.w300,
        color: CupertinoColors.white,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
