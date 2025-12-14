part of 'focus_bloc.dart';

abstract class FocusState extends Equatable {
  const FocusState();

  @override
  List<Object> get props => [];
}

class FocusInitial extends FocusState {}

class FocusInProgress extends FocusState {
  final int remaining;

  const FocusInProgress(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class FocusPaused extends FocusState {
  final int remaining;

  const FocusPaused(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class FocusComplete extends FocusState {}
