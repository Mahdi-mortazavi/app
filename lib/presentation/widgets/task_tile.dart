import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../data/models/task.dart';
import '../../providers/task_providers.dart';
import '../navigation.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          LiquidGlassTap(
            onTap: () => openTaskSheet(context, task),
            onLongPress: task.subtasks.isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      ref.read(tasksProvider.notifier).toggleComplete(task.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isDone
                          ? AppColors.accentGreen
                          : CupertinoColors.transparent,
                      border: Border.all(
                        color: widget.isDone
                            ? AppColors.accentGreen
                            : CupertinoColors.white.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: widget.isDone
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 14,
                            color: CupertinoColors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              widget.isDone ? TextDecoration.lineThrough : null,
                          color: widget.isDone
                              ? AppColors.inkSubdued
                              : AppColors.ink,
                        ),
                      ),
                      if (!widget.isDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  task.category,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption,
                                ),
                              ),
                              if (task.reminder != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.alarm,
                                  size: 12,
                                  color: AppColors.inkSubdued,
                                ),
                                Text(
                                  ' ${task.reminder!.hour}:${task.reminder!.minute.toString().padLeft(2, '0')}',
                                  style: AppTypography.caption,
                                ),
                              ],
                              if (task.subtasks.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.list_bullet,
                                  size: 12,
                                  color: AppColors.inkSubdued,
                                ),
                                Text(
                                  ' ${task.subtasks.where((e) => e.isCompleted).length}/${task.subtasks.length}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!widget.isDone) ...[
                  const SizedBox(width: 8),
                  Hero(
                    tag: 'play_${task.id}',
                    child: GestureDetector(
                      onTap: () => openFocusPage(context, task),
                      child: const Icon(
                        CupertinoIcons.play_circle_fill,
                        size: 30,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_expanded && task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LiquidGlass(
                borderRadius: BorderRadius.circular(20),
                blurSigma: 18,
                child: Column(
                  children: task.subtasks
                      .map(
                        (s) => CupertinoListTile(
                          leading: Icon(
                            s.isCompleted
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color: s.isCompleted
                                ? AppColors.accentGreen
                                : AppColors.inkSubdued,
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
                            ),
                          ),
                          onTap: () => ref
                              .read(tasksProvider.notifier)
                              .toggleSubTask(task.id, s.id),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
