import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../data/models/task.dart';
import '../../providers/task_providers.dart';
import '../navigation.dart';

class PinnedCard extends ConsumerWidget {
  const PinnedCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 156,
      child: LiquidGlassTap(
        onTap: () => openTaskSheet(context, task),
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () =>
                      ref.read(tasksProvider.notifier).toggleComplete(task.id),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white.withOpacity(0.7),
                        width: 2,
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
                    '${task.duration} دقیقه',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ),
                const SizedBox(width: 6),
                Hero(
                  tag: 'play_${task.id}',
                  child: GestureDetector(
                    onTap: () => openFocusPage(context, task),
                    child: const Icon(
                      CupertinoIcons.play_circle_fill,
                      size: 26,
                      color: AppColors.ink,
                    ),
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
