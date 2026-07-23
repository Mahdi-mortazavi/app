import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// Appearance-aware type scale. All text uses Vazirmatn (declared as a native
/// font family in pubspec.yaml, so every weight resolves offline and inside
/// modal sheets); the timer reuses it with tabular figures so digits never
/// reflow.
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

  static const _family = 'Vazirmatn';

  /// Large collapsing screen title (≈ iOS LargeTitle 34/41).
  TextStyle get largeTitle => TextStyle(
        fontFamily: _family,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: _c.ink,
        letterSpacing: -0.8,
        height: 41 / 34,
      );

  /// Section / sheet titles (≈ Title3 20/25).
  TextStyle get title => TextStyle(
        fontFamily: _family,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _c.ink,
        letterSpacing: -0.3,
        height: 25 / 20,
      );

  /// Body copy (≈ Callout 16/21 — tuned for Persian).
  TextStyle get body => TextStyle(
        fontFamily: _family,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _c.ink,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Secondary metadata (≈ Caption1 12/16, slightly positive tracking).
  TextStyle get caption => TextStyle(
        fontFamily: _family,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _c.inkSubdued,
        letterSpacing: 0.2,
        height: 16 / 12,
      );

  /// Focus countdown — always on the immersive dark canvas, so its color is
  /// appearance-independent by design. The readout is Persian digits
  /// (Fmt.clock), rendered in Vazirmatn Light with tabular figures to keep
  /// their widths stable as the clock ticks.
  static const TextStyle timer = TextStyle(
        fontFamily: _family,
        fontSize: 68,
        fontWeight: FontWeight.w300,
        color: CupertinoColors.white,
        fontFeatures: [FontFeature.tabularFigures()],
      );
}
