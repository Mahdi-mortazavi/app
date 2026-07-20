import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/haptics/haptics_service.dart';
import '../core/notifications/notification_service.dart';
import '../data/models/task.dart';
import '../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return SharedPreferencesTaskRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService();
});

/// Owns the task list end to end: loading, persistence, and keeping
/// reminders scheduled in lockstep with edits. UI never touches
/// [TaskRepository] or [NotificationService] directly.
class TasksNotifier extends AsyncNotifier<List<Task>> {
  bool _checkedMissedReminders = false;

  TaskRepository get _repo => ref.read(taskRepositoryProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);
  HapticsService get _haptics => ref.read(hapticsServiceProvider);

  @override
  Future<List<Task>> build() async {
    final tasks = await _repo.loadTasks();
    if (!_checkedMissedReminders) {
      _checkedMissedReminders = true;
      unawaited(_notifyMissedReminders(tasks));
    }
    return tasks;
  }

  /// If the app was killed while a reminder should have fired, surface it
  /// immediately on next launch instead of silently dropping it. Bounded to
  /// a 30-minute grace window so very old reminders don't resurface.
  Future<void> _notifyMissedReminders(List<Task> tasks) async {
    final now = DateTime.now();
    for (final t in tasks) {
      final r = t.reminder;
      if (r == null || t.isCompleted) continue;
      final missedBy = now.difference(r);
      if (missedBy > Duration.zero && missedBy < const Duration(minutes: 30)) {
        await _notifications.showNow(
          id: t.id,
          title: 'یادآوری از دست رفته',
          body: t.title,
        );
      }
    }
  }

  Future<void> addTask(Task task) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([task, ...current]);
    final persisted = _persistCurrent();
    await _schedule(task);
    await _haptics.success();
    await persisted;
  }

  Future<void> updateTask(Task task) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final t in current) if (t.id == task.id) task else t,
    ]);
    final persisted = _persistCurrent();
    await _schedule(task);
    await _haptics.success();
    await persisted;
  }

  Future<void> toggleComplete(int id) async {
    final current = state.valueOrNull ?? [];
    final index = current.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final toggled = current[index].copyWith(isCompleted: !current[index].isCompleted);
    state = AsyncData([...current]..[index] = toggled);
    final persisted = _persistCurrent();

    if (toggled.isCompleted) {
      await _notifications.cancel(id);
      await _haptics.success();
    } else {
      await _schedule(toggled);
      await _haptics.light();
    }
    await persisted;
  }

  Future<void> delete(int id) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => t.id != id).toList());
    final persisted = _persistCurrent();
    await _notifications.cancel(id);
    await _haptics.warning();
    await persisted;
  }

  Future<void> toggleSubTask(int taskId, String subId) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final t in current)
        if (t.id == taskId)
          t.copyWith(
            subtasks: [
              for (final s in t.subtasks)
                if (s.id == subId)
                  s.copyWith(isCompleted: !s.isCompleted)
                else
                  s,
            ],
          )
        else
          t,
    ]);
    final persisted = _persistCurrent();
    await _haptics.selection();
    await persisted;
  }

  /// Always cancels first: an edit that removes or moves a reminder must
  /// not leave the old scheduled notification behind.
  Future<void> _schedule(Task t) async {
    await _notifications.cancel(t.id);
    if (t.reminder == null || t.isCompleted || !t.reminder!.isAfter(DateTime.now())) {
      return;
    }
    await _notifications.scheduleReminder(
      id: t.id,
      title: 'یادآوری',
      body: t.title,
      time: t.reminder!,
    );
  }

  /// Serialized persistence. Mutations used to persist a captured snapshot
  /// *after* variable-latency side effects (haptics, notification calls),
  /// so two rapid mutations could write out of order and the slower, staler
  /// snapshot would win — silently dropping the newer change on next launch.
  ///
  /// Writes are now (1) enqueued immediately after the state update and
  /// (2) chained on a queue that saves the CURRENT state at write time, so
  /// the last write always contains every change regardless of side-effect
  /// timing.
  Future<void> _persistQueue = Future.value();

  Future<void> _persistCurrent() {
    _persistQueue = _persistQueue.then((_) async {
      final tasks = state.valueOrNull;
      if (tasks != null) await _repo.saveTasks(tasks);
    });
    return _persistQueue;
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

final pinnedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
  return tasks.where((t) => t.isPinned && !t.isCompleted).toList();
});

final activeTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
  return tasks.where((t) => !t.isPinned && !t.isCompleted).toList();
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
  return tasks.where((t) => t.isCompleted).toList();
});
