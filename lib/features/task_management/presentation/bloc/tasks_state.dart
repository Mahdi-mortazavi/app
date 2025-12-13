import 'package:equatable/equatable.dart';
import 'package:app/features/task_management/domain/entities/task.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoadInProgress extends TasksState {}

class TasksLoadSuccess extends TasksState {
  final List<Task> tasks;

  const TasksLoadSuccess(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class TasksLoadFailure extends TasksState {}
