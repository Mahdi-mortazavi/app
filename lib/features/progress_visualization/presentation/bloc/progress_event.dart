import 'package:equatable/equatable.dart';
import 'package:app/features/task_management/domain/entities/task.dart';

enum ChartView { daily, weekly, monthly }

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object> get props => [];
}

class LoadProgress extends ProgressEvent {}

class UpdateProgress extends ProgressEvent {
  final List<Task> tasks;

  const UpdateProgress(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class ChangeChartView extends ProgressEvent {
  final ChartView view;

  const ChangeChartView(this.view);

  @override
  List<Object> get props => [view];
}
