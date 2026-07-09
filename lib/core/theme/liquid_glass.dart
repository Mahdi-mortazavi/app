import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

/// A single reusable "Liquid Glass" surface: a deep backdrop blur, a subtle
/// multi-stop tint gradient (so the glass reads as curved rather than flat),
/// and a sub-pixel translucent border catching the light along one edge.
///
/// Every card/sheet/button in the app should be built from this instead of
/// a flat `Container`, so the whole UI reads as one consistent material.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 30,
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
    final borderColor =
        (onDark ? CupertinoColors.white : AppColors.glassBorder);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: onDark ? 0.14 : tintOpacity),
                tint.withValues(alpha: onDark ? 0.05 : tintOpacity * 0.45),
              ],
            ),
            border: Border.all(color: borderColor.withValues(alpha: 0.35), width: 0.6),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: onDark ? 0.35 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A [LiquidGlass] surface that reacts to touch with an organic scale-down,
/// standing in for every previously-flat `GestureDetector` + `Container`
/// pairing in the app.
class LiquidGlassTap extends StatefulWidget {
  const LiquidGlassTap({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 30,
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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
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
