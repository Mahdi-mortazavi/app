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

class TaskTile extends ConsumerStatefulWidget {
  const TaskTile({super.key, required this.task, this.isDone = false});

  final Task task;
  final bool isDone;

  @override
  ConsumerState<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends ConsumerState<TaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final hasSubtasks = task.subtasks.isNotEmpty;
    final c = NavaColors.of(context);
    final type = AppTypography.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          SolidCardTap(
            onTap: () => openTaskSheet(context, task),
            onLongPress:
                hasSubtasks ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _Checkbox(
                  isDone: widget.isDone,
                  onTap: () =>
                      ref.read(tasksProvider.notifier).toggleComplete(task.id),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.body.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              widget.isDone ? TextDecoration.lineThrough : null,
                          color: widget.isDone ? c.inkSubdued : c.ink,
                        ),
                      ),
                      if (!widget.isDone) _MetaRow(task: task),
                    ],
                  ),
                ),
                if (!widget.isDone)
                  Hero(
                    tag: 'play_${task.id}',
                    child: TappableIcon(
                      icon: CupertinoIcons.play_circle_fill,
                      size: 30,
                      color: c.ink,
                      semanticLabel: 'شروع تمرکز روی ${task.title}',
                      onTap: () => openFocusPage(context, task),
                    ),
                  ),
              ],
            ),
          ),
          if (_expanded && hasSubtasks)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SolidCard(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Column(
                  children: [
                    for (final s in task.subtasks)
                      CupertinoListTile(
                        leading: Icon(
                          s.isCompleted
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.circle,
                          color:
                              s.isCompleted ? AppColors.accentGreen : c.inkSubdued,
                          size: 18,
                        ),
                        title: Text(
                          s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: s.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontSize: 13,
                            color: c.ink,
                          ),
                        ),
                        onTap: () => ref
                            .read(tasksProvider.notifier)
                            .toggleSubTask(task.id, s.id),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isDone, required this.onTap});

  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    return Semantics(
      button: true,
      checked: isDone,
      label: isDone ? 'انجام‌شده — لغو تکمیل' : 'علامت‌گذاری به‌عنوان انجام‌شده',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isDone ? AppColors.accentGreen : CupertinoColors.transparent,
                border: Border.all(
                  color: isDone
                      ? AppColors.accentGreen
                      : c.inkSubdued.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 14,
                      color: CupertinoColors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    final type = AppTypography.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Flexible(
            child: Text(
              task.category,
              overflow: TextOverflow.ellipsis,
              style: type.caption,
            ),
          ),
          if (task.reminder != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(CupertinoIcons.alarm, size: 12, color: c.inkSubdued),
            const SizedBox(width: 2),
            Text(Fmt.timeOfDay(task.reminder!), style: type.caption),
          ],
          if (task.subtasks.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(CupertinoIcons.list_bullet, size: 12, color: c.inkSubdued),
            const SizedBox(width: 2),
            Text(
              Fmt.fa(
                '${task.subtasks.where((e) => e.isCompleted).length}/${task.subtasks.length}',
              ),
              style: type.caption,
            ),
          ],
        ],
      ),
    );
  }
}
