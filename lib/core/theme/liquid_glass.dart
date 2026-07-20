import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// A single reusable "Liquid Glass" surface: continuous ("squircle") corners,
/// a deep backdrop blur, a subtle tint gradient, a hairline border, and a
/// specular highlight along the top edge that reads as caught light.
///
/// Every card/sheet/button in the app is built from this, so the whole UI
/// reads as one consistent material. Each surface is wrapped in a
/// [RepaintBoundary]: BackdropFilter is one of the most expensive raster
/// operations, and the boundary keeps a scrolling list of glass tiles from
/// re-rasterizing untouched neighbors.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.tint = AppColors.glassTint,
    this.tintOpacity = 0.55,
    this.padding,
    this.onDark = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tint;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;

  /// Flips the gradient/border balance for glass placed over dark imagery
  /// (e.g. the Focus screen), where a light gradient would wash out.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = onDark ? CupertinoColors.white : AppColors.glassBorder;
    // Continuous corners read far less round than a circular radius of the
    // same value, so scale up to match the intended visual radius.
    final shape = ContinuousRectangleBorder(
      borderRadius: borderRadius * 2.2,
      side: BorderSide(
        color: borderColor.withValues(alpha: 0.35),
        width: 0.6,
      ),
    );

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
                  tint.withValues(alpha: onDark ? 0.14 : tintOpacity),
                  tint.withValues(alpha: onDark ? 0.05 : tintOpacity * 0.45),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Specular highlight: a faint band of light along the top
                // edge, like a real pane catching overhead light.
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0),
                          CupertinoColors.white
                              .withValues(alpha: onDark ? 0.35 : 0.8),
                          CupertinoColors.white.withValues(alpha: 0),
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

/// A [LiquidGlass] surface that reacts to touch with an organic, springy
/// scale-down, standing in for every previously-flat `GestureDetector` +
/// `Container` pairing in the app.
class LiquidGlassTap extends StatefulWidget {
  const LiquidGlassTap({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 24,
    this.tint = AppColors.glassTint,
    this.tintOpacity = 0.55,
    this.padding,
    this.onDark = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tint;
  final double tintOpacity;
  final EdgeInsetsGeometry? padding;
  final bool onDark;

  @override
  State<LiquidGlassTap> createState() => _LiquidGlassTapState();
}

class _LiquidGlassTapState extends State<LiquidGlassTap> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 220),
        // Overshooting release curve for a springy, physical feel.
        curve: Curves.easeOutBack,
        child: LiquidGlass(
          borderRadius: widget.borderRadius,
          blurSigma: widget.blurSigma,
          tint: widget.tint,
          tintOpacity: widget.tintOpacity,
          padding: widget.padding,
          onDark: widget.onDark,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Full-bleed background gradient shared by every screen in light mode —
/// the "canvas" the glass surfaces float above.
class LiquidCanvas extends StatelessWidget {
  const LiquidCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.canvasGradient,
        ),
      ),
      child: child,
    );
  }
}
