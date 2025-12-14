import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/features/task_management/presentation/widgets/task_form.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:app/features/task_management/presentation/pages/focus_page.dart';
import 'package:app/core/theme/app_theme.dart';

class PinnedCard extends StatelessWidget {
  final Task task;
  const PinnedCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context, task),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: AppTheme.radius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.read<TasksBloc>().add(ToggleTaskCompletion(task.id)),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.pin_fill,
                  size: 14,
                  color: AppTheme.orange,
                ),
              ],
            ),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${task.duration} دقیقه",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSub,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openFocus(context, task),
                  child: const Icon(
                    CupertinoIcons.play_circle_fill,
                    size: 26,
                    color: AppTheme.textMain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
