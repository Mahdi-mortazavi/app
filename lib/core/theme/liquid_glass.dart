import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../design/motion.dart';
import 'app_colors.dart';

/// ── Surface system ──────────────────────────────────────────────────────
/// Two materials, per the Liquid Glass laws:
///
///  • [LiquidGlass] — the floating chrome material (headers, primary action,
///    sheets, immersive controls). Backdrop blur + tint + specular top edge +
///    darkened outer hairline. NEVER used for content or inside scrolling
///    lists; a screen composes at most a few of these.
///
///  • [SolidCard] — the content material (task tiles, pinned cards, stat
///    cards). Opaque scheme fill, continuous corners, hairline border, soft
///    shadow. Zero blur cost, safe at any list length.
///
/// Both respect the OS reduced-transparency/high-contrast signal: glass
/// falls back to an opaque surface with a defined border.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.tint,
    this.tintOpacity = 0.55,
    this.padding,
    this.onDark = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;

  /// Overrides the scheme glass tint (e.g. the ink-tinted add button).
  final Color? tint;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;

  /// For glass over the always-dark Focus canvas.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    final dark = onDark || c.isDark;
    final tint = this.tint ?? c.glassTint;
    final reduceTransparency = MediaQuery.highContrastOf(context);

    // Continuous corners read far less round than a circular radius of the
    // same value, so scale up to match the intended visual radius.
    final shape = ContinuousRectangleBorder(
      borderRadius: borderRadius * 2.2,
      side: BorderSide(
        // Darkened outer edge for depth separation (2026 spec) in light;
        // a light hairline does the separating on dark canvases.
        color: dark
            ? c.glassSpecular.withValues(alpha: 0.22)
            : const Color(0x1A000000),
        width: 0.6,
      ),
    );

    if (reduceTransparency) {
      // Reduced transparency / increased contrast: frosty → solid.
      return DecoratedBox(
        decoration: ShapeDecoration(shape: shape, color: c.surface),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
    }

    return RepaintBoundary(
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: shape,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: dark ? 0.35 : tintOpacity),
                  tint.withValues(alpha: dark ? 0.18 : tintOpacity * 0.45),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Specular highlight: brighter light-catching top edge
                // (2026 revision).
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.glassSpecular.withValues(alpha: 0),
                          c.glassSpecular.withValues(alpha: dark ? 0.4 : 0.8),
                          c.glassSpecular.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tappable chrome glass with spring press feedback (interruptible,
/// pointer-down response — see [PressScale]).
class LiquidGlassTap extends StatelessWidget {
  const LiquidGlassTap({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.tint,
    this.tintOpacity = 0.55,
    this.padding,
    this.onDark = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? tint;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: LiquidGlass(
        borderRadius: borderRadius,
        blurSigma: blurSigma,
        tint: tint,
        tintOpacity: tintOpacity,
        padding: padding,
        onDark: onDark,
        child: child,
      ),
    );
  }
}

/// The content material: opaque, continuous-corner card. No blur — content
/// is sacred and cheap to scroll.
class SolidCard extends StatelessWidget {
  const SolidCard({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    final shape = ContinuousRectangleBorder(
      borderRadius: borderRadius * 2.2,
      side: BorderSide(color: c.surfaceBorder, width: 0.6),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: c.surface,
        shadows: [
          BoxShadow(
            color: const Color(0xFF000000)
                .withValues(alpha: c.isDark ? 0.30 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

/// Tappable content card with the same spring press interaction as chrome —
/// one motion language everywhere.
class SolidCardTap extends StatelessWidget {
  const SolidCardTap({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SolidCard(
        borderRadius: borderRadius,
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Full-bleed appearance-aware background gradient — the canvas the surfaces
/// float above.
class LiquidCanvas extends StatelessWidget {
  const LiquidCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.canvasTop, c.canvasBottom],
        ),
      ),
      child: child,
    );
  }
}
