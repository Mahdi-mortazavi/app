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

class MockGetTasks extends Mock implements GetTasks {}

class MockSaveTasks extends Mock implements SaveTasks {}

class MockNotificationService extends Mock implements NotificationService {}

class MockVibrationService extends Mock implements VibrationService {}

void main() {
  late TasksBloc tasksBloc;
  late MockGetTasks mockGetTasks;
  late MockSaveTasks mockSaveTasks;
  late MockNotificationService mockNotificationService;
  late MockVibrationService mockVibrationService;

  setUp(() {
    mockGetTasks = MockGetTasks();
    mockSaveTasks = MockSaveTasks();
    mockNotificationService = MockNotificationService();
    mockVibrationService = MockVibrationService();
    tasksBloc = TasksBloc(
      getTasks: mockGetTasks,
      saveTasks: mockSaveTasks,
      notificationService: mockNotificationService,
      vibrationService: mockVibrationService,
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
        when(mockGetTasks()).thenAnswer((_) async => [tTask]);
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
        when(mockGetTasks()).thenAnswer((_) async => []);
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
        when(mockGetTasks()).thenAnswer((_) async => [tTask]);
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
        when(mockGetTasks()).thenAnswer((_) async => [tTask]);
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
        when(mockGetTasks()).thenAnswer((_) async => [tTask]);
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
        when(mockGetTasks()).thenAnswer((_) async => [tTask]);
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
