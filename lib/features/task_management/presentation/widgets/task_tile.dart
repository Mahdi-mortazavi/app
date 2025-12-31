import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/features/task_management/presentation/widgets/task_form.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/features/task_management/presentation/pages/focus_page.dart';
import 'package:app/core/theme/app_theme.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final bool isDone;

  const TaskTile({super.key, required this.task, this.isDone = false});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            if (widget.task.subtasks.isNotEmpty) {
              setState(() => _expanded = !_expanded);
            }
          },
          onTap: () => _openSheet(context, widget.task),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: AppTheme.radius,
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context
                      .read<TasksBloc>()
                      .add(ToggleTaskCompletion(widget.task.id)),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.isDone ? AppTheme.green : Colors.transparent,
                      border: Border.all(
                        color: widget.isDone
                            ? AppTheme.green
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: widget.isDone
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 14,
                            color: Colors.white,
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
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              widget.isDone ? TextDecoration.lineThrough : null,
                          color: widget.isDone
                              ? AppTheme.textSub
                              : AppTheme.textMain,
                        ),
                      ),
                      if (!widget.isDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                widget.task.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSub,
                                ),
                              ),
                              if (widget.task.reminder != null) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.alarm,
                                  size: 12,
                                  color: AppTheme.textSub,
                                ),
                                Text(
                                  " ${widget.task.reminder!.hour}:${widget.task.reminder!.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSub,
                                  ),
                                ),
                              ],
                              if (widget.task.subtasks.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.list_bullet,
                                  size: 12,
                                  color: AppTheme.textSub,
                                ),
                                Text(
                                  " ${widget.task.subtasks.where((e) => e.isCompleted).length}/${widget.task.subtasks.length}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSub,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!widget.isDone)
                  GestureDetector(
                    onTap: () => _openFocus(context, widget.task),
                    child: const Icon(
                      CupertinoIcons.play_circle_fill,
                      size: 30,
                      color: AppTheme.textMain,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.task.subtasks.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: widget.task.subtasks
                  .map(
                    (s) => ListTile(
                      dense: true,
                      leading: Icon(
                        s.isCompleted
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        color: s.isCompleted ? AppTheme.green : Colors.grey,
                        size: 18,
                      ),
                      title: Text(
                        s.title,
                        style: TextStyle(
                          decoration:
                              s.isCompleted ? TextDecoration.lineThrough : null,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => context
                          .read<TasksBloc>()
                          .add(ToggleSubTaskCompletion(widget.task.id, s.id)),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _openSheet(BuildContext context, Task task) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shadow: const BoxShadow(color: Colors.transparent),
      builder: (context) => TaskForm(task: task),
    );
  }

  void _openFocus(BuildContext context, Task task) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FocusPage(task: task),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }
}
