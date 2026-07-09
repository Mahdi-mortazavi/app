import 'sub_task.dart';

class Task {
  Task({
    required this.id,
    required this.title,
    this.category = 'شخصی',
    this.duration = 25,
    this.reminder,
    this.isPinned = false,
    this.isCompleted = false,
    List<SubTask>? subtasks,
  }) : subtasks = subtasks ?? const [];

  final int id;
  final String title;
  final String category;
  final int duration;
  final DateTime? reminder;
  final bool isPinned;
  final bool isCompleted;
  final List<SubTask> subtasks;

  Task copyWith({
    String? title,
    String? category,
    int? duration,
    DateTime? reminder,
    bool clearReminder = false,
    bool? isPinned,
    bool? isCompleted,
    List<SubTask>? subtasks,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        duration: duration ?? this.duration,
        reminder: clearReminder ? null : (reminder ?? this.reminder),
        isPinned: isPinned ?? this.isPinned,
        isCompleted: isCompleted ?? this.isCompleted,
        subtasks: subtasks ?? this.subtasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'duration': duration,
        'reminder': reminder?.toIso8601String(),
        'isPinned': isPinned,
        'isCompleted': isCompleted,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? 'شخصی',
        duration: json['duration'] as int? ?? 25,
        reminder: json['reminder'] != null
            ? DateTime.parse(json['reminder'] as String)
            : null,
        isPinned: json['isPinned'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
        subtasks: (json['subtasks'] as List<dynamic>? ?? [])
            .map((s) => SubTask.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
