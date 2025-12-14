import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/bloc/focus_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'dart:ui';
import 'package:app/core/service_locator.dart';
import 'package:app/core/theme/app_theme.dart';

class FocusPage extends StatelessWidget {
  final Task task;
  const FocusPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FocusBloc(vibrationService: sl())..add(StartFocus(task.duration * 60)),
      child: BlocBuilder<FocusBloc, FocusState>(
        builder: (context, state) {
          final remaining = state is FocusInProgress
              ? state.remaining
              : state is FocusPaused
                  ? state.remaining
                  : 0;
          final total = task.duration * 60;

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
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
                        alignment: Alignment.topLeft,
                        child: CupertinoButton(
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white54,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        task.category,
                        style: TextStyle(
                          color: _glowColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 140,
                            lineWidth: 6,
                            percent: remaining / total,
                            backgroundColor: Colors.white10,
                            progressColor:
                                remaining < 60 ? AppTheme.red : _glowColor,
                            circularStrokeCap: CircularStrokeCap.round,
                            animateFromLastPercent: true,
                            animation: true,
                            animationDuration: 1000,
                          ),
                          Text(
                            "${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}",
                            style: AppTheme.timerFont.copyWith(
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      if (state is! FocusComplete)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GlassBtn(
                              "-5",
                              () => context.read<FocusBloc>().add(StartFocus(remaining - 300)),
                            ),
                            const SizedBox(width: 32),
                            GestureDetector(
                              onTap: () {
                                if (state is FocusInProgress) {
                                  context.read<FocusBloc>().add(PauseFocus());
                                } else if (state is FocusPaused) {
                                  context.read<FocusBloc>().add(ResumeFocus());
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Icon(
                                      state is FocusInProgress
                                          ? CupertinoIcons.pause_fill
                                          : CupertinoIcons.play_fill,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            _GlassBtn(
                              "+5",
                              () => context.read<FocusBloc>().add(StartFocus(remaining + 300)),
                            ),
                          ],
                        )
                      else
                        CupertinoButton(
                          onPressed: () {
                            context.read<TasksBloc>().add(ToggleTaskCompletion(task.id));
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "اتمام",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color get _glowColor {
    switch (task.category) {
      case 'کاری':
        return AppTheme.blue;
      case 'خرید':
        return AppTheme.orange;
      case 'مطالعه':
        return AppTheme.purple;
      default:
        return AppTheme.green;
    }
  }
}

class _GlassBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlassBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
