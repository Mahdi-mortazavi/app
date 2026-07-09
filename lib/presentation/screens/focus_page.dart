import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
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
    final session = ref.watch(focusTimerProvider);
    if (session == null) return const SizedBox.shrink();

    final remaining = session.remainingSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');

    return CupertinoPageScaffold(
      backgroundColor: AppColors.focusCanvas,
      child: Stack(
        alignment: Alignment.center,
        children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _glowColor.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: _glowColor.withOpacity(0.3),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  duration: 4.seconds,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.3, 1.3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 32),
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
                  if (session.completed)
                    _CompletionBadge(color: _glowColor)
                  else
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 140,
                          lineWidth: 6,
                          percent: session.progress,
                          backgroundColor: CupertinoColors.white.withOpacity(0.08),
                          progressColor:
                              remaining < 60 ? AppColors.accentRed : _glowColor,
                          circularStrokeCap: CircularStrokeCap.round,
                          animateFromLastPercent: true,
                          animation: true,
                          animationDuration: 900,
                        ),
                        Text('$minutes:$seconds', style: AppTypography.timer),
                      ],
                    ),
                  const SizedBox(height: 48),
                  if (session.completed)
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

class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(focusTimerProvider);
    if (session == null) return const SizedBox.shrink();
    final notifier = ref.read(focusTimerProvider.notifier);
    final haptics = ref.read(hapticsServiceProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GlassStepButton(label: '-5', onTap: () => notifier.adjust(-300)),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: () {
            haptics.light();
            session.isRunning ? notifier.pause() : notifier.resume();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white.withOpacity(0.25)),
                ),
                child: Icon(
                  session.isRunning
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_fill,
                  color: CupertinoColors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        _GlassStepButton(label: '+5', onTap: () => notifier.adjust(300)),
      ],
    );
  }
}

class _GlassStepButton extends StatelessWidget {
  const _GlassStepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(30),
        blurSigma: 12,
        onDark: true,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(CupertinoIcons.check_mark_circled_solid, color: color, size: 96)
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        const Text(
          'تمام شد!',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(30),
        onDark: true,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: const Text(
          'بازگشت',
          style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
