import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/task_management/data/models/task_model.dart';
import 'package:app/core/constants.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> saveTasks(List<TaskModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final jsonString = sharedPreferences.getString(kTasksBox);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await sharedPreferences.setString(kTasksBox, jsonEncode(jsonList));
  }
}
