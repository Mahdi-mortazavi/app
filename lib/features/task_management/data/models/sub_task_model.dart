import 'package:app/features/task_management/domain/entities/sub_task.dart';

class SubTaskModel extends SubTask {
  const SubTaskModel({
    required String id,
    required String title,
    bool isCompleted = false,
  }) : super(id: id, title: title, isCompleted: isCompleted);

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
