import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/haptics/haptics_service.dart';
import 'package:app/core/notifications/notification_service.dart';
import 'package:app/data/models/task.dart';
import 'package:app/data/repositories/task_repository.dart';
import 'package:app/providers/task_providers.dart';

/// A repository whose FIRST write is artificially slow. Before the write
/// queue, a slow first write would land after a fast second write and
/// overwrite it with a stale list; with the queue, writes are ordered and
/// always save the current state.
class _SlowFirstWriteRepository implements TaskRepository {
  List<Task>? stored;
  final List<List<int>> writeLog = [];
  int _writes = 0;

  @override
  Future<List<Task>> loadTasks() async => stored ?? [];

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    _writes++;
    if (_writes == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
    stored = tasks;
    writeLog.add([
      for (final t in tasks)
        if (t.isCompleted) t.id,
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rapid successive toggles never persist a stale list', () async {
    final repo = _SlowFirstWriteRepository()
      ..stored = [
        Task(id: 1, title: 'اول'),
        Task(id: 2, title: 'دوم'),
      ];

    final container = ProviderContainer(overrides: [
      taskRepositoryProvider.overrideWithValue(repo),
      // Real services are safe in tests (they no-op off-device), but they add
      // latency variance; the queue must be correct regardless.
      notificationServiceProvider.overrideWithValue(NotificationService()),
      hapticsServiceProvider.overrideWithValue(HapticsService()),
    ]);
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    final notifier = container.read(tasksProvider.notifier);

    // Fire two mutations back-to-back without awaiting the first.
    final f1 = notifier.toggleComplete(1);
    final f2 = notifier.toggleComplete(2);
    await Future.wait([f1, f2]);

    // Whatever the side-effect timing, the FINAL stored list must contain
    // BOTH completions — the second change can never be lost.
    final completedIds =
        repo.stored!.where((t) => t.isCompleted).map((t) => t.id).toSet();
    expect(completedIds, {1, 2});

    // And the last write in the log is the complete one.
    expect(repo.writeLog.last.toSet(), {1, 2});
  });
}
