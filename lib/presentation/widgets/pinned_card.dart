import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/task.dart';
import '../../providers/task_providers.dart';
import '../navigation.dart';
import 'tappable_icon.dart';

class PinnedCard extends ConsumerWidget {
  const PinnedCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 156,
      child: LiquidGlassTap(
        onTap: () => openTaskSheet(context, task),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  button: true,
                  checked: false,
                  label: 'علامت‌گذاری به‌عنوان انجام‌شده',
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        ref.read(tasksProvider.notifier).toggleComplete(task.id),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.white.withValues(alpha: 0.7),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.pin_fill,
                  size: 14,
                  color: AppColors.accentOrange,
                ),
              ],
            ),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    Fmt.fa('${task.duration} دقیقه'),
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Hero(
                  tag: 'play_${task.id}',
                  child: TappableIcon(
                    icon: CupertinoIcons.play_circle_fill,
                    size: 26,
                    color: AppColors.ink,
                    minTarget: 36,
                    semanticLabel: 'شروع تمرکز روی ${task.title}',
                    onTap: () => openFocusPage(context, task),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
