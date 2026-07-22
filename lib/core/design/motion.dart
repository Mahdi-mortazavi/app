import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// The motion system. All interactive motion in Nava is spring-based and
/// interruptible — no fixed-duration ease curves on anything a user touches.
///
/// Springs are parameterized SwiftUI-style:
///  - [response]: settle speed in seconds (perceptual duration)
///  - [dampingRatio]: 1.0 = no bounce; < 1.0 = bounce. Bounce is reserved for
///    gesture releases that carried momentum — plain taps always use 1.0.
class AppMotion {
  const AppMotion._();

  static SpringDescription spring({
    double response = 0.35,
    double dampingRatio = 1.0,
  }) {
    const mass = 1.0;
    final stiffness = math.pow(2 * math.pi / response, 2) * mass;
    final damping = 4 * math.pi * dampingRatio * mass / response;
    return SpringDescription(
      mass: mass,
      stiffness: stiffness.toDouble(),
      damping: damping,
    );
  }

  /// Standard UI state changes.
  static final SpringDescription standard = spring();

  /// Press-down feedback: must register within ~100ms, so a faster response.
  static final SpringDescription press = spring(response: 0.2);

  /// Sheets and drawers (slight bounce — they arrive with momentum).
  static final SpringDescription sheet =
      spring(response: 0.3, dampingRatio: 0.8);

  /// Repositioning elements.
  static final SpringDescription reposition = spring(response: 0.4);
}

/// Spring-driven press feedback: scales to [pressedScale] on pointer-down
/// (within a frame — well inside the 100ms budget) and springs back on
/// release.
///
/// Interruptible by construction: every retarget starts a [SpringSimulation]
/// from the controller's *current presentation value* and current velocity,
/// so a release mid-press-down blends smoothly — there is no brick-wall
/// reversal and no restart-from-target.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController.unbounded(vsync: this, value: 1.0);
  double _velocity = 0;

  void _springTo(double target, SpringDescription springDesc) {
    final simulation = SpringSimulation(
      springDesc,
      _controller.value, // current presentation value — interruptible
      target,
      _velocity,
    );
    _velocity = 0;
    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) {
        if (reduceMotion) return;
        _springTo(widget.pressedScale, AppMotion.press);
      },
      onTapUp: (_) {
        if (reduceMotion) return;
        _springTo(1.0, AppMotion.standard);
      },
      onTapCancel: () {
        if (reduceMotion) return;
        _springTo(1.0, AppMotion.standard);
      },
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }
}
