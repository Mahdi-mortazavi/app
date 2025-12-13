part of 'focus_bloc.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object> get props => [];
}

class StartFocus extends FocusEvent {
  final int duration;

  const StartFocus(this.duration);

  @override
  List<Object> get props => [duration];
}

class PauseFocus extends FocusEvent {}

class ResumeFocus extends FocusEvent {}

class Tick extends FocusEvent {}

class ResetFocus extends FocusEvent {}
