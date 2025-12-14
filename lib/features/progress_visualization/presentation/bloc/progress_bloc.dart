import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_event.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_state.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_state.dart';
import 'package:shamsi_date/shamsi_date.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final TasksBloc tasksBloc;
  late StreamSubscription tasksSubscription;

  ProgressBloc({required this.tasksBloc}) : super(ProgressInitial()) {
    tasksSubscription = tasksBloc.stream.listen((state) {
      if (state is TasksLoadSuccess) {
        add(UpdateProgress(state.tasks));
      }
    });

    on<LoadProgress>(_onLoadProgress);
    on<UpdateProgress>(_onUpdateProgress);
    on<ChangeChartView>(_onChangeChartView);
  }

  void _onLoadProgress(LoadProgress event, Emitter<ProgressState> emit) {
    if (tasksBloc.state is TasksLoadSuccess) {
      final tasks = (tasksBloc.state as TasksLoadSuccess).tasks;
      final data = _getChartData(tasks, ChartView.weekly);
      emit(ProgressLoadSuccess(data: data, view: ChartView.weekly));
    }
  }

  void _onUpdateProgress(UpdateProgress event, Emitter<ProgressState> emit) {
    if (state is ProgressLoadSuccess) {
      final view = (state as ProgressLoadSuccess).view;
      final data = _getChartData(event.tasks, view);
      emit(ProgressLoadSuccess(data: data, view: view));
    }
  }

  void _onChangeChartView(ChangeChartView event, Emitter<ProgressState> emit) {
    if (tasksBloc.state is TasksLoadSuccess) {
      final tasks = (tasksBloc.state as TasksLoadSuccess).tasks;
      final data = _getChartData(tasks, event.view);
      emit(ProgressLoadSuccess(data: data, view: event.view));
    }
  }

  List<int> _getChartData(List<Task> allTasks, ChartView view) {
    final now = DateTime.now();
    final completed = allTasks.where((t) => t.isCompleted && t.completionDate != null);

    switch (view) {
      case ChartView.daily:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          return completed
              .where((t) =>
                  t.completionDate!.year == day.year &&
                  t.completionDate!.month == day.month &&
                  t.completionDate!.day == day.day)
              .length;
        });
      case ChartView.weekly:
        return List.generate(4, (i) {
          final weekStart = now.subtract(Duration(days: (now.weekday + 1) % 7 + (3 - i) * 7));
          return completed.where((t) {
            final cd = t.completionDate!;
            return cd.isAfter(weekStart) &&
                cd.isBefore(weekStart.add(const Duration(days: 7)));
          }).length;
        });
      case ChartView.monthly:
        return List.generate(6, (i) {
          final date = DateTime(now.year, now.month - (5 - i), 1);
          return completed
              .where((t) =>
                  t.completionDate!.year == date.year &&
                  t.completionDate!.month == date.month)
              .length;
        });
    }
  }

  @override
  Future<void> close() {
    tasksSubscription.cancel();
    return super.close();
  }
}
