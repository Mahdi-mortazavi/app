import 'package:flutter/cupertino.dart';

import '../../core/theme/app_spacing.dart';

/// An icon button that always meets Apple's 44pt minimum touch target and
/// always carries a VoiceOver label — the two things every bare
/// `GestureDetector(child: Icon(...))` in this app was missing.
///
/// The visible icon stays its natural [size]; the tappable/hit area is padded
/// out to at least [AppSpacing.minTouchTarget] without affecting layout size
/// beyond that.
class TappableIcon extends StatelessWidget {
  const TappableIcon({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color,
    this.size = 24,
    this.minTarget = AppSpacing.minTouchTarget,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Spoken by VoiceOver. Describes the action, not the glyph
  /// (e.g. "علامت‌گذاری به‌عنوان انجام‌شده", not "دایره").
  final String semanticLabel;

  final Color? color;
  final double size;
  final double minTarget;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minTarget, minHeight: minTarget),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}
