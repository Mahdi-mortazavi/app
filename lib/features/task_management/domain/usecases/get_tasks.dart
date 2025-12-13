import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/domain/repositories/task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<List<Task>> call() async {
    return await repository.getTasks();
  }
}
