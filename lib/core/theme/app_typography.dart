import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Appearance-aware type scale. Farsi copy uses Vazirmatn; the timer uses a
/// monospaced face so digits never reflow.
///
/// Tracking is size-specific, per Apple's typography guidance: display sizes
/// get negative tracking that tightens as size grows, body sits at ~0, and
/// captions get a small positive bump for legibility. Line height tightens
/// as size grows.
class AppTypography {
  const AppTypography._(this._c);

  final NavaColors _c;

  static AppTypography of(BuildContext context) =>
      AppTypography._(NavaColors.of(context));

  /// Large collapsing screen title (≈ iOS LargeTitle 34/41).
  TextStyle get largeTitle => GoogleFonts.vazirmatn(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: _c.ink,
        letterSpacing: -0.8,
        height: 41 / 34,
      );

  /// Section / sheet titles (≈ Title3 20/25).
  TextStyle get title => GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _c.ink,
        letterSpacing: -0.3,
        height: 25 / 20,
      );

  /// Body copy (≈ Callout 16/21 — tuned for Persian).
  TextStyle get body => GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _c.ink,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Secondary metadata (≈ Caption1 12/16, slightly positive tracking).
  TextStyle get caption => GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _c.inkSubdued,
        letterSpacing: 0.2,
        height: 16 / 12,
      );

  /// Focus countdown — always on the immersive dark canvas, so its color is
  /// appearance-independent by design.
  static TextStyle get timer => GoogleFonts.ibmPlexMono(
        fontSize: 68,
        fontWeight: FontWeight.w300,
        color: CupertinoColors.white,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
