import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/data/datasources/task_local_data_source.dart';
import 'package:app/features/task_management/data/models/task_model.dart';
import 'package:app/features/task_management/domain/repositories/task_repository.dart';
import 'package:app/features/task_management/data/models/sub_task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Task>> getTasks() async {
    final taskModels = await localDataSource.getTasks();
    return taskModels.map((model) => model as Task).toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final taskModels = tasks.map((task) {
      return TaskModel(
        id: task.id,
        title: task.title,
        category: task.category,
        duration: task.duration,
        reminder: task.reminder,
        isPinned: task.isPinned,
        isCompleted: task.isCompleted,
        subtasks: task.subtasks
            .map((subtask) => SubTaskModel(
                  id: subtask.id,
                  title: subtask.title,
                  isCompleted: subtask.isCompleted,
                ))
            .toList(),
        completionDate: task.completionDate,
      );
    }).toList();
    await localDataSource.saveTasks(taskModels);
  }
}
