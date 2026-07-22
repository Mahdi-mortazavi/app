import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatting.dart';
import '../../data/models/sub_task.dart';
import '../../data/models/task.dart';
import '../../providers/task_providers.dart';
import 'glass_badge.dart';
import 'permission_primer.dart';

const _categories = ['شخصی', 'کاری', 'خرید', 'مطالعه'];
const _durations = [25, 45, 90];

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  late final TextEditingController _titleController;
  String _category = _categories.first;
  int _duration = _durations.first;
  bool _pinned = false;
  DateTime? _reminder;
  List<SubTask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    // Rebuild on text change so the Save button reflects whether there's a
    // non-empty title, instead of silently no-op'ing on an empty save.
    _titleController.addListener(_onTitleChanged);
    if (t != null) {
      _category = t.category;
      _duration = t.duration;
      _pinned = t.isPinned;
      _reminder = t.reminder;
      _subtasks = t.subtasks.map((s) => s.copyWith()).toList();
    }
  }

  void _onTitleChanged() => setState(() {});

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = NavaColors.of(context);
    final type = AppTypography.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: ColoredBox(
        color: c.sheet.withValues(alpha: 0.96),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.inkSubdued.withValues(alpha: 0.3),
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
                      style: type.title,
                    ),
                    if (widget.task != null)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: _delete,
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: AppColors.accentRed,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'عنوان کار...',
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: c.inkSubdued.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  style: type.body,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GlassBadge(
                        _category,
                        onTap: () => setState(() {
                          final i = _categories.indexOf(_category);
                          _category = _categories[(i + 1) % _categories.length];
                        }),
                      ),
                      const SizedBox(width: 8),
                      GlassBadge(
                        Fmt.fa('$_duration دقیقه'),
                        icon: CupertinoIcons.timer,
                        onTap: () => setState(() {
                          final i = _durations.indexOf(_duration);
                          _duration = _durations[(i + 1) % _durations.length];
                        }),
                      ),
                      const SizedBox(width: 8),
                      GlassBadge(
                        _pinned ? 'پین شده' : 'پین',
                        icon: _pinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                        active: _pinned,
                        onTap: () => setState(() => _pinned = !_pinned),
                      ),
                      const SizedBox(width: 8),
                      GlassBadge(
                        _reminder != null ? Fmt.timeOfDay(_reminder!) : 'یادآور',
                        icon: _reminder != null
                            ? CupertinoIcons.alarm_fill
                            : CupertinoIcons.alarm,
                        active: _reminder != null,
                        onTap: _pickReminderTime,
                      ),
                      if (_reminder != null) ...[
                        const SizedBox(width: 8),
                        GlassBadge(
                          'حذف یادآور',
                          icon: CupertinoIcons.xmark,
                          onTap: () => setState(() => _reminder = null),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Fmt.fa(
                        'زیرمجموعه (${_subtasks.where((e) => e.isCompleted).length}/${_subtasks.length})',
                      ),
                      style: type.caption,
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _addSubtask,
                      child: const Icon(
                        CupertinoIcons.add_circled,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final s in _subtasks)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _subtasks = [
                              for (final x in _subtasks)
                                if (x.id == s.id)
                                  x.copyWith(isCompleted: !x.isCompleted)
                                else
                                  x,
                            ];
                          }),
                          child: Icon(
                            s.isCompleted
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color: s.isCompleted
                                ? AppColors.accentGreen
                                : c.inkSubdued,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: c.ink,
                              decoration:
                                  s.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _subtasks = _subtasks.where((x) => x.id != s.id).toList(),
                          ),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: AppColors.accentRed,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                CupertinoButton(
                  // Tinted = the primary call to action (semantic accent).
                  color: AppColors.accentBlue,
                  disabledColor: AppColors.accentBlue.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  // Disabled (not silently no-op) until there's a title, so the
                  // button's state always matches what tapping it will do.
                  onPressed: _canSave ? _save : null,
                  child: const Text(
                    'ذخیره',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSubtask() {
    String value = '';
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('افزودن مورد'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(autofocus: true, onChanged: (v) => value = v),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('لغو'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (value.isNotEmpty) {
                setState(() => _subtasks = [..._subtasks, SubTask(title: value)]);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }

  /// Builds a reminder for [hour]:[minute] today, or tomorrow if that moment
  /// has already passed — so "remind me at 8:00" never silently drops because
  /// 8:00 was earlier today.
  DateTime _nextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  Future<void> _pickReminderTime() async {
    final granted = await ensureNotificationPermission(context, ref);
    if (!granted || !mounted) return;

    // Seed the picker with the current selection (or now) and only commit on
    // "تایید", so scrolling the wheel doesn't thrash setState every frame.
    final initial = _reminder ?? DateTime.now();
    var pending = _nextOccurrence(initial.hour, initial.minute);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(popupContext),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        setState(() => _reminder = null);
                        Navigator.pop(popupContext);
                      },
                      child: const Text(
                        'حذف',
                        style: TextStyle(color: AppColors.accentRed),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        setState(() => _reminder = pending);
                        Navigator.pop(popupContext);
                      },
                      child: const Text('تایید'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: initial,
                  onDateTimeChanged: (t) =>
                      pending = _nextOccurrence(t.hour, t.minute),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delete() {
    final task = widget.task;
    if (task == null) return;
    ref.read(tasksProvider.notifier).delete(task.id);
    Navigator.pop(context);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      category: _category,
      duration: _duration,
      reminder: _reminder,
      isPinned: _pinned,
      isCompleted: widget.task?.isCompleted ?? false,
      subtasks: _subtasks,
    );

    final notifier = ref.read(tasksProvider.notifier);
    if (widget.task == null) {
      notifier.addTask(task);
    } else {
      notifier.updateTask(task);
    }
    Navigator.pop(context);
  }
}
