/// Spacing, radius, and touch-target tokens on a consistent 4pt grid.
///
/// Before this, layout constants (24 / 16 / 12 / 28 …) were repeated as magic
/// numbers across every widget. Centralizing them keeps rhythm consistent and
/// makes a global spacing change a one-line edit.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard screen gutter.
  static const double gutter = 24;

  /// Apple HIG minimum interactive target. Any tappable control smaller than
  /// this visually should still occupy at least this much hit area.
  static const double minTouchTarget = 44;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 14;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double sheet = 32;
  static const double pill = 40;
}
