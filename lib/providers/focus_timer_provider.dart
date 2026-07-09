import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/task.dart';
import 'task_providers.dart';

/// A focus session's state is always derived from wall-clock time
/// ([runningSince] + [remainingAtSync]), never from a decrementing counter.
/// That's what makes it safe across backgrounding: however long the app was
/// suspended, [remainingSeconds] recomputes correctly the instant it's read
/// again, with no drift and no catch-up loop needed.
class FocusSessionState {
  const FocusSessionState({
    required this.task,
    required this.totalSeconds,
    required this.remainingAtSync,
    required this.runningSince,
    this.completed = false,
  });

  final Task task;
  final int totalSeconds;
  final int remainingAtSync;
  final DateTime? runningSince;
  final bool completed;

  bool get isRunning => runningSince != null;

  int get remainingSeconds {
    if (runningSince == null) return remainingAtSync;
    final elapsed = DateTime.now().difference(runningSince!).inSeconds;
    final left = remainingAtSync - elapsed;
    return left < 0 ? 0 : left;
  }

  double get progress =>
      totalSeconds == 0 ? 0 : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

  FocusSessionState copyWith({
    int? totalSeconds,
    int? remainingAtSync,
    Object? runningSince = _unset,
    bool? completed,
  }) {
    return FocusSessionState(
      task: task,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingAtSync: remainingAtSync ?? this.remainingAtSync,
      runningSince:
          identical(runningSince, _unset) ? this.runningSince : runningSince as DateTime?,
      completed: completed ?? this.completed,
    );
  }
}

const _unset = Object();

/// Distinct notification-id offset so a scheduled "session complete" alert
/// never collides with a task's own reminder notification (which uses the
/// task's own id).
const _focusNotificationIdOffset = 900000;

class FocusTimerNotifier extends Notifier<FocusSessionState?> {
  Timer? _ticker;

  @override
  FocusSessionState? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  void start(Task task) {
    _ticker?.cancel();
    final total = task.duration * 60;
    state = FocusSessionState(
      task: task,
      totalSeconds: total,
      remainingAtSync: total,
      runningSince: DateTime.now(),
    );
    _startTicking();
  }

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s == null || !s.isRunning) return;
      if (s.remainingSeconds <= 0) {
        _complete();
      } else {
        // New instance so watchers rebuild — values are re-derived from
        // wall clock, this call just prompts a redraw.
        state = s.copyWith();
      }
    });
  }

  void pause() {
    final s = state;
    if (s == null || !s.isRunning) return;
    _ticker?.cancel();
    state = s.copyWith(remainingAtSync: s.remainingSeconds, runningSince: null);
  }

  void resume() {
    final s = state;
    if (s == null || s.isRunning || s.remainingSeconds <= 0) return;
    state = s.copyWith(remainingAtSync: s.remainingSeconds, runningSince: DateTime.now());
    _startTicking();
  }

  void adjust(int deltaSeconds) {
    final s = state;
    if (s == null) return;
    final newRemaining = (s.remainingSeconds + deltaSeconds).clamp(0, 24 * 60 * 60);
    state = s.copyWith(
      remainingAtSync: newRemaining,
      runningSince: s.isRunning ? DateTime.now() : null,
    );
    if (newRemaining <= 0) _complete();
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    final s = state;
    if (s == null || s.completed) return;
    state = s.copyWith(remainingAtSync: 0, runningSince: null, completed: true);
    await ref.read(hapticsServiceProvider).timerComplete();
    await ref.read(notificationServiceProvider).cancel(
          _focusNotificationIdOffset + s.task.id,
        );
  }

  /// Called by the Focus screen's [WidgetsBindingObserver] when the app is
  /// backgrounded mid-session: since a suspended isolate can't be trusted to
  /// fire haptics on time, schedule a real system notification for the
  /// moment the countdown will actually hit zero.
  Future<void> onAppBackgrounded() async {
    final s = state;
    if (s == null || !s.isRunning || s.completed) return;
    final fireAt = DateTime.now().add(Duration(seconds: s.remainingSeconds));
    await ref.read(notificationServiceProvider).scheduleReminder(
          id: _focusNotificationIdOffset + s.task.id,
          title: 'زمان تمرکز به پایان رسید',
          body: s.task.title,
          time: fireAt,
        );
  }

  /// Called on resume: the pending "session complete" notification is no
  /// longer needed since the app itself will now handle completion, and the
  /// remaining time is re-derived immediately from wall clock.
  Future<void> onAppResumed() async {
    final s = state;
    if (s == null) return;
    await ref.read(notificationServiceProvider).cancel(
          _focusNotificationIdOffset + s.task.id,
        );
    if (s.remainingSeconds <= 0) {
      await _complete();
    } else if (s.isRunning) {
      state = s.copyWith();
    }
  }

  void stop() {
    _ticker?.cancel();
    final s = state;
    if (s != null) {
      ref.read(notificationServiceProvider).cancel(_focusNotificationIdOffset + s.task.id);
    }
    state = null;
  }
}

final focusTimerProvider = NotifierProvider<FocusTimerNotifier, FocusSessionState?>(
  FocusTimerNotifier.new,
);
