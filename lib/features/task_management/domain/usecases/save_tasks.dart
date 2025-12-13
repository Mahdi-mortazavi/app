import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/domain/repositories/task_repository.dart';

class SaveTasks {
  final TaskRepository repository;

  SaveTasks(this.repository);

  Future<void> call(List<Task> tasks) async {
    await repository.saveTasks(tasks);
  }
}
