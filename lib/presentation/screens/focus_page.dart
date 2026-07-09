import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/task.dart';
import '../../providers/focus_timer_provider.dart';
import '../../providers/task_providers.dart';

class FocusPage extends ConsumerStatefulWidget {
  const FocusPage({super.key, required this.task});

  final Task task;

  @override
  ConsumerState<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends ConsumerState<FocusPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(focusTimerProvider.notifier).start(widget.task);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(focusTimerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        notifier.onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        notifier.onAppResumed();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(focusTimerProvider.notifier).stop();
    super.dispose();
  }

  Color get _glowColor => AppColors.categoryColor(widget.task.category);

  @override
  Widget build(BuildContext context) {
    // Watch only the two booleans that change page structure — NOT the whole
    // session — so the per-second timer tick rebuilds just the readout subtree
    // below, not this entire tree + the glow + the controls.
    final completed =
        ref.watch(focusTimerProvider.select((s) => s?.completed ?? false));
    final isRunning =
        ref.watch(focusTimerProvider.select((s) => s?.isRunning ?? false));
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.focusCanvas,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _PulsingGlow(
            color: _glowColor,
            // The glow only breathes while actively counting down. Paused or
            // finished it holds still — no wasted 60fps repaints, and it
            // respects the system Reduce Motion setting.
            active: isRunning && !completed && !reduceMotion,
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: CupertinoColors.white,
                      semanticLabel: 'بستن جلسه تمرکز',
                    ),
                  ),
                ),
                const Spacer(),
                Hero(
                  tag: 'play_${widget.task.id}',
                  child: const SizedBox.shrink(),
                ),
                Text(
                  widget.task.category,
                  style: TextStyle(
                    color: _glowColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Text(
                    widget.task.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                if (completed)
                  _CompletionBadge(color: _glowColor, reduceMotion: reduceMotion)
                else
                  _TimerReadout(accent: _glowColor, reduceMotion: reduceMotion),
                const SizedBox(height: 48),
                if (completed)
                  _DoneButton(onTap: () => Navigator.pop(context))
                else
                  const _Controls(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Self-contained breathing glow. Owns its own controller so it is not
/// rebuilt by the per-second timer tick, and starts/stops with [active].
class _PulsingGlow extends StatefulWidget {
  const _PulsingGlow({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) _sync();
  }

  void _sync() {
    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.25).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 120,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The only part of the screen that rebuilds every second.
class _TimerReadout extends ConsumerWidget {
  const _TimerReadout({required this.accent, required this.reduceMotion});

  final Color accent;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining =
        ref.watch(focusTimerProvider.select((s) => s?.remainingSeconds ?? 0));
    final progress =
        ref.watch(focusTimerProvider.select((s) => s?.progress ?? 0.0));

    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    return Semantics(
      label: 'زمان باقی‌مانده: $minutes دقیقه و $seconds ثانیه',
      excludeSemantics: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularPercentIndicator(
            radius: 140,
            lineWidth: 6,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: CupertinoColors.white.withOpacity(0.08),
            progressColor: remaining < 60 ? AppColors.accentRed : accent,
            circularStrokeCap: CircularStrokeCap.round,
            animateFromLastPercent: true,
            animation: !reduceMotion,
            animationDuration: 900,
          ),
          Text(Fmt.clock(remaining), style: AppTypography.timer),
        ],
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning =
        ref.watch(focusTimerProvider.select((s) => s?.isRunning ?? false));
    final notifier = ref.read(focusTimerProvider.notifier);
    final haptics = ref.read(hapticsServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GlassStepButton(
          label: '−۵',
          semanticLabel: 'کاهش پنج دقیقه',
          onTap: () => notifier.adjust(-300),
        ),
        const SizedBox(width: AppSpacing.xxl),
        Semantics(
          button: true,
          label: isRunning ? 'توقف موقت' : 'ادامه',
          child: GestureDetector(
            onTap: () {
              haptics.light();
              isRunning ? notifier.pause() : notifier.resume();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.minTouchTarget),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: CupertinoColors.white.withOpacity(0.25)),
                  ),
                  child: Icon(
                    isRunning
                        ? CupertinoIcons.pause_fill
                        : CupertinoIcons.play_fill,
                    color: CupertinoColors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        _GlassStepButton(
          label: '+۵',
          semanticLabel: 'افزودن پنج دقیقه',
          onTap: () => notifier.adjust(300),
        ),
      ],
    );
  }
}

class _GlassStepButton extends StatelessWidget {
  const _GlassStepButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(30),
          blurSigma: 12,
          onDark: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.color, required this.reduceMotion});

  final Color color;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      CupertinoIcons.check_mark_circled_solid,
      color: color,
      size: 96,
    );
    return Semantics(
      label: 'جلسه تمرکز کامل شد',
      child: Column(
        children: [
          reduceMotion
              ? icon
              : icon.animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'تمام شد!',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'بازگشت',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(30),
          onDark: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: AppSpacing.lg,
          ),
          child: const Text(
            'بازگشت',
            style: TextStyle(
              color: CupertinoColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
