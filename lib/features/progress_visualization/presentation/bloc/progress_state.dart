import 'package:equatable/equatable.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_event.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoadInProgress extends ProgressState {}

class ProgressLoadSuccess extends ProgressState {
  final List<int> data;
  final ChartView view;

  const ProgressLoadSuccess({required this.data, required this.view});

  ProgressLoadSuccess copyWith({
    List<int>? data,
    ChartView? view,
  }) {
    return ProgressLoadSuccess(
      data: data ?? this.data,
      view: view ?? this.view,
    );
  }

  @override
  List<Object> get props => [data, view];
}

class ProgressLoadFailure extends ProgressState {}
