import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/notifications/domain/services/vibration_service.dart';
import 'package:equatable/equatable.dart';

part 'focus_event.dart';
part 'focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final VibrationService vibrationService;
  Timer? _timer;

  FocusBloc({required this.vibrationService}) : super(FocusInitial()) {
    on<StartFocus>(_onStartFocus);
    on<PauseFocus>(_onPauseFocus);
    on<ResumeFocus>(_onResumeFocus);
    on<Tick>(_onTick);
    on<ResetFocus>(_onResetFocus);
  }

  void _onStartFocus(StartFocus event, Emitter<FocusState> emit) {
    emit(FocusInProgress(event.duration));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Tick());
    });
  }

  void _onPauseFocus(PauseFocus event, Emitter<FocusState> emit) {
    if (state is FocusInProgress) {
      _timer?.cancel();
      emit(FocusPaused((state as FocusInProgress).remaining));
    }
  }

  void _onResumeFocus(ResumeFocus event, Emitter<FocusState> emit) {
    if (state is FocusPaused) {
      emit(FocusInProgress((state as FocusPaused).remaining));
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(Tick());
      });
    }
  }

  void _onTick(Tick event, Emitter<FocusState> emit) {
    if (state is FocusInProgress) {
      final remaining = (state as FocusInProgress).remaining - 1;
      if (remaining > 0) {
        emit(FocusInProgress(remaining));
      } else {
        _timer?.cancel();
        emit(FocusComplete());
        vibrationService.vibrateSuccess();
      }
    }
  }

  void _onResetFocus(ResetFocus event, Emitter<FocusState> emit) {
    _timer?.cancel();
    emit(FocusInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
