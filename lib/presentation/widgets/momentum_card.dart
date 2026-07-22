import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../core/utils/formatting.dart';
import '../../providers/stats_provider.dart';

/// The "Momentum" summary: a daily-goal progress ring (goal-gradient effect)
/// plus a streak chain (habit loop / loss aversion). Tapping the goal cycles
/// the target, so the commitment stays the user's own choice.
///
/// Content, not chrome → rendered on a [SolidCard].
class MomentumCard extends ConsumerWidget {
  const MomentumCard({super.key});

  static const _goalOptions = [1, 3, 5, 8];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(statsViewProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final c = NavaColors.of(context);
    final type = AppTypography.of(context);

    final ringColor =
        view.goalReached ? AppColors.accentGreen : AppColors.accentBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: SolidCard(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Semantics(
              label:
                  'هدف امروز: ${view.sessionsToday} از ${view.dailyGoal} جلسه',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () {
                  final i = _goalOptions.indexOf(view.dailyGoal);
                  final next = _goalOptions[(i + 1) % _goalOptions.length];
                  ref.read(statsProvider.notifier).setDailyGoal(next);
                },
                child: CircularPercentIndicator(
                  radius: 34,
                  lineWidth: 6,
                  percent: view.goalProgress,
                  backgroundColor: c.inkSubdued.withValues(alpha: 0.15),
                  progressColor: ringColor,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: !reduceMotion,
                  animateFromLastPercent: true,
                  center: Text(
                    Fmt.fa('${view.sessionsToday}/${view.dailyGoal}'),
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    view.goalReached ? 'هدف امروز کامل شد 🎉' : 'تمرکز امروز',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'برای تغییر هدف روی حلقه بزن',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: type.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StreakBadge(streak: view.streak),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    final c = NavaColors.of(context);
    final type = AppTypography.of(context);
    return Semantics(
      label: 'زنجیره: $streak روز پیاپی',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? CupertinoIcons.flame_fill : CupertinoIcons.flame,
            color: active ? AppColors.accentOrange : c.inkSubdued,
            size: 26,
          ),
          const SizedBox(height: 2),
          Text(
            Fmt.fa('$streak'),
            style: type.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: active ? c.ink : c.inkSubdued,
            ),
          ),
        ],
      ),
    );
  }
}
