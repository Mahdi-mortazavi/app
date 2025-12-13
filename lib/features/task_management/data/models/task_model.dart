import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/data/models/sub_task_model.dart';

class TaskModel extends Task {
  const TaskModel({
    required int id,
    required String title,
    String category = 'شخصی',
    int duration = 25,
    DateTime? reminder,
    bool isPinned = false,
    bool isCompleted = false,
    List<SubTaskModel> subtasks = const [],
    DateTime? completionDate,
  }) : super(
          id: id,
          title: title,
          category: category,
          duration: duration,
          reminder: reminder,
          isPinned: isPinned,
          isCompleted: isCompleted,
          subtasks: subtasks,
          completionDate: completionDate,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      duration: json['duration'],
      reminder: json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
      isPinned: json['isPinned'],
      isCompleted: json['isCompleted'],
      subtasks: (json['subtasks'] as List)
          .map((s) => SubTaskModel.fromJson(s))
          .toList(),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'duration': duration,
      'reminder': reminder?.toIso8601String(),
      'isPinned': isPinned,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => (s as SubTaskModel).toJson()).toList(),
      'completionDate': completionDate?.toIso8601String(),
    };
  }
}
