import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Pure persistence — no notification/haptics concerns here. The Riverpod
/// notifier owns orchestration (schedule/cancel reminders, haptics); this
/// class only knows how to read and write the task list.
abstract class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
}

class SharedPreferencesTaskRepository implements TaskRepository {
  static const _storageKey = 'ive_tasks_final_v6';

  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }
}
