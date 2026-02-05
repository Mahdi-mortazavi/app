import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:app/features/task_management/domain/usecases/get_tasks.dart';
import 'package:app/features/task_management/domain/usecases/save_tasks.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/notifications/domain/services/vibration_service.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_state.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/domain/entities/sub_task.dart';

class FakeGetTasks extends Fake implements GetTasks {
  List<Task> tasks = [];
  @override
  Future<List<Task>> call() async => tasks;
}

class FakeSaveTasks extends Fake implements SaveTasks {
  @override
  Future<void> call(List<Task> tasks) async {}
}

class FakeNotificationService extends Fake implements NotificationService {
  @override
  Future<void> scheduleNotification(Task task) async {}
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  Future<void> init({required Function(int) onNotificationTapped}) async {}
}

class FakeVibrationService extends Fake implements VibrationService {
  @override
  Future<void> vibrateSuccess() async {}
  @override
  Future<void> vibrateLight() async {}
}

void main() {
  late TasksBloc tasksBloc;
  late FakeGetTasks fakeGetTasks;
  late FakeSaveTasks fakeSaveTasks;
  late FakeNotificationService fakeNotificationService;
  late FakeVibrationService fakeVibrationService;

  setUp(() {
    fakeGetTasks = FakeGetTasks();
    fakeSaveTasks = FakeSaveTasks();
    fakeNotificationService = FakeNotificationService();
    fakeVibrationService = FakeVibrationService();

    tasksBloc = TasksBloc(
      getTasks: fakeGetTasks,
      saveTasks: fakeSaveTasks,
      notificationService: fakeNotificationService,
      vibrationService: fakeVibrationService,
    );
  });

  tearDown(() {
    tasksBloc.close();
  });

  group('TasksBloc', () {
    final tSubTask = SubTask(id: '1', title: 'Test SubTask');
    final tTask = Task(id: 1, title: 'Test Task', subtasks: [tSubTask]);

    test('initial state is TasksInitial', () {
      expect(tasksBloc.state, TasksInitial());
    });

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadInProgress, TasksLoadSuccess] when LoadTasks is added.',
      build: () {
        fakeGetTasks.tasks = [tTask];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        TasksLoadInProgress(),
        TasksLoadSuccess([tTask]),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadSuccess] when AddTask is added.',
      build: () {
        fakeGetTasks.tasks = [];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(AddTask(tTask)),
      seed: () => TasksLoadSuccess([]),
      expect: () => [
        TasksLoadSuccess([tTask]),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadSuccess] when UpdateTask is added.',
      build: () {
        fakeGetTasks.tasks = [tTask];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(UpdateTask(tTask.copyWith(title: 'Updated Task'))),
      seed: () => TasksLoadSuccess([tTask]),
      expect: () => [
        TasksLoadSuccess([tTask.copyWith(title: 'Updated Task')]),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadSuccess] when DeleteTask is added.',
      build: () {
        fakeGetTasks.tasks = [tTask];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(DeleteTask(tTask.id)),
      seed: () => TasksLoadSuccess([tTask]),
      expect: () => [
        TasksLoadSuccess([]),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadSuccess] when ToggleTaskCompletion is added.',
      build: () {
        fakeGetTasks.tasks = [tTask];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(ToggleTaskCompletion(tTask.id)),
      seed: () => TasksLoadSuccess([tTask]),
      expect: () => [
        isA<TasksLoadSuccess>().having(
          (state) => state.tasks.first.isCompleted,
          'isCompleted',
          true,
        ),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'emits [TasksLoadSuccess] when ToggleSubTaskCompletion is added.',
      build: () {
        fakeGetTasks.tasks = [tTask];
        return tasksBloc;
      },
      act: (bloc) => bloc.add(ToggleSubTaskCompletion(tTask.id, tSubTask.id)),
      seed: () => TasksLoadSuccess([tTask]),
      expect: () => [
        isA<TasksLoadSuccess>().having(
          (state) => state.tasks.first.subtasks.first.isCompleted,
          'isCompleted',
          true,
        ),
      ],
    );
  });
}
