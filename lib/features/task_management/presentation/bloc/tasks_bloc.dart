import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/task_management/domain/usecases/get_tasks.dart';
import 'package:app/features/task_management/domain/usecases/save_tasks.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_state.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/notifications/domain/services/vibration_service.dart';
import 'package:app/features/task_management/domain/entities/sub_task.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasks;
  final SaveTasks saveTasks;
  final NotificationService notificationService;
  final VibrationService vibrationService;

  TasksBloc({
    required this.getTasks,
    required this.saveTasks,
    required this.notificationService,
    required this.vibrationService,
  }) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<ToggleSubTaskCompletion>(_onToggleSubTaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await getTasks();
      emit(TasksLoadSuccess(tasks));
    } catch (_) {
      emit(TasksLoadFailure());
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final List<Task> updatedTasks = List.from((state as TasksLoadSuccess).tasks)..insert(0, event.task);
      await saveTasks(updatedTasks);
      await notificationService.scheduleNotification(event.task);
      emit(TasksLoadSuccess(updatedTasks));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final List<Task> updatedTasks = (state as TasksLoadSuccess).tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();
      await saveTasks(updatedTasks);
      await notificationService.scheduleNotification(event.task);
      emit(TasksLoadSuccess(updatedTasks));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final List<Task> updatedTasks = (state as TasksLoadSuccess).tasks.where((task) => task.id != event.id).toList();
      await saveTasks(updatedTasks);
      await notificationService.cancelNotification(event.id);
      emit(TasksLoadSuccess(updatedTasks));
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final List<Task> updatedTasks = (state as TasksLoadSuccess).tasks.map((task) {
        if (task.id == event.id) {
          final updatedTask = task.copyWith(
            isCompleted: !task.isCompleted,
            completionDate: !task.isCompleted ? DateTime.now() : null,
          );
          if (updatedTask.isCompleted) {
            notificationService.cancelNotification(updatedTask.id);
            vibrationService.vibrateSuccess();
          } else {
            notificationService.scheduleNotification(updatedTask);
            vibrationService.vibrateLight();
          }
          return updatedTask;
        }
        return task;
      }).toList();
      await saveTasks(updatedTasks);
      emit(TasksLoadSuccess(updatedTasks));
    }
  }

  Future<void> _onToggleSubTaskCompletion(ToggleSubTaskCompletion event, Emitter<TasksState> emit) async {
    if (state is TasksLoadSuccess) {
      final List<Task> updatedTasks = (state as TasksLoadSuccess).tasks.map((task) {
        if (task.id == event.taskId) {
          final updatedSubtasks = task.subtasks.map((subtask) {
            if (subtask.id == event.subTaskId) {
              return subtask.copyWith(isCompleted: !subtask.isCompleted);
            }
            return subtask;
          }).toList();
          return task.copyWith(subtasks: updatedSubtasks);
        }
        return task;
      }).toList();
      await saveTasks(updatedTasks);
      emit(TasksLoadSuccess(updatedTasks));
    }
  }
}
