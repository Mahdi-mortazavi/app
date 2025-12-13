import 'package:equatable/equatable.dart';
import 'package:app/features/task_management/domain/entities/sub_task.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String category;
  final int duration;
  final DateTime? reminder;
  final bool isPinned;
  final bool isCompleted;
  final List<SubTask> subtasks;
  final DateTime? completionDate;

  const Task({
    required this.id,
    required this.title,
    this.category = 'شخصی',
    this.duration = 25,
    this.reminder,
    this.isPinned = false,
    this.isCompleted = false,
    this.subtasks = const [],
    this.completionDate,
  });

  Task copyWith({
    int? id,
    String? title,
    String? category,
    int? duration,
    DateTime? reminder,
    bool? isPinned,
    bool? isCompleted,
    List<SubTask>? subtasks,
    DateTime? completionDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      reminder: reminder ?? this.reminder,
      isPinned: isPinned ?? this.isPinned,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        duration,
        reminder,
        isPinned,
        isCompleted,
        subtasks,
        completionDate,
      ];
}
