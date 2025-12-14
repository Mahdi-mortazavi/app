import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/task_management/domain/entities/sub_task.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/core/theme/app_theme.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController _ctrl;
  String _cat = 'شخصی';
  int _dur = 25;
  bool _pin = false;
  DateTime? _rem;
  List<SubTask> _subs = [];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _ctrl = TextEditingController(text: t?.title ?? '');
    if (t != null) {
      _cat = t.category;
      _dur = t.duration;
      _pin = t.isPinned;
      _rem = t.reminder;
      _subs = List.from(
        t.subtasks.map(
          (e) => SubTask(id: e.id, title: e.title, isCompleted: e.isCompleted),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? 'کار جدید' : 'ویرایش',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.task != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: AppTheme.red,
                      ),
                      onPressed: () {
                        context.read<TasksBloc>().add(DeleteTask(widget.task!.id));
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _ctrl,
                placeholder: 'عنوان کار...',
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                style: AppTheme.body,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Badge(
                      _cat,
                      onTap: () => setState(
                        () => _cat = ['شخصی', 'کاری', 'خرید', 'مطالعه'][([
                                  'شخصی',
                                  'کاری',
                                  'خرید',
                                  'مطالعه',
                                ].indexOf(_cat) +
                                1) %
                            4],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      "$_dur دقیقه",
                      icon: CupertinoIcons.timer,
                      onTap: () => setState(
                        () => _dur = (_dur == 25
                            ? 45
                            : _dur == 45
                                ? 90
                                : 25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      _pin ? "پین شده" : "پین",
                      icon: _pin ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                      active: _pin,
                      onTap: () => setState(() => _pin = !_pin),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      _rem != null
                          ? "${_rem!.hour}:${_rem!.minute.toString().padLeft(2, '0')}"
                          : "یادآور",
                      icon: CupertinoIcons.alarm,
                      active: _rem != null,
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "زیرمجموعه (${_subs.where((e) => e.isCompleted).length}/${_subs.length})",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSub,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: const Icon(
                      CupertinoIcons.add_circled,
                      color: AppTheme.blue,
                    ),
                    onPressed: _addSub,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_subs.isNotEmpty)
                ..._subs.map(
                  (s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final index = _subs.indexOf(s);
                              _subs[index] = s.copyWith(isCompleted: !s.isCompleted);
                            });
                          },
                          child: Icon(
                            s.isCompleted
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color:
                                s.isCompleted ? AppTheme.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.title,
                            style: TextStyle(
                              decoration: s.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _subs.remove(s)),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: AppTheme.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: AppTheme.textMain,
                borderRadius: BorderRadius.circular(16),
                onPressed: _save,
                child: const Text(
                  "ذخیره",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSub() {
    String t = "";
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("افزودن مورد"),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(autofocus: true, onChanged: (v) => t = v),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("لغو"),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("افزودن"),
            onPressed: () {
              if (t.isNotEmpty) {
                setState(() => _subs.add(SubTask(id: DateTime.now().microsecondsSinceEpoch.toString(), title: t)));
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: AppTheme.card,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          onDateTimeChanged: (t) {
            final now = DateTime.now();
            setState(
              () => _rem = DateTime(
                now.year,
                now.month,
                now.day,
                t.hour,
                t.minute,
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() {
    if (_ctrl.text.isEmpty) return;
    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _ctrl.text,
      category: _cat,
      duration: _dur,
      reminder: _rem,
      isPinned: _pin,
      isCompleted: widget.task?.isCompleted ?? false,
      subtasks: _subs,
      completionDate: widget.task?.completionDate,
    );

    if (widget.task == null) {
      context.read<TasksBloc>().add(AddTask(task));
    } else {
      context.read<TasksBloc>().add(UpdateTask(task));
    }
    Navigator.pop(context);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _Badge(
    this.label, {
    this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.textMain : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: active ? Colors.white : AppTheme.textSub),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : AppTheme.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
