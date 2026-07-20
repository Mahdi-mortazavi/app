import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/focus_stats.dart';
import '../data/repositories/stats_repository.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return SharedPreferencesStatsRepository();
});

/// Owns the momentum data. The streak arithmetic lives here so it has one
/// tested home and the UI only ever reads a resolved [FocusStatsView].
class StatsNotifier extends AsyncNotifier<FocusStats> {
  StatsRepository get _repo => ref.read(statsRepositoryProvider);

  @override
  Future<FocusStats> build() => _repo.load();

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Records one completed focus session and advances the streak.
  ///
  /// - same day as last session → just increment today's count
  /// - the day after → chain continues, streak += 1
  /// - a gap (or first ever) → chain restarts at 1
  ///
  /// [now] is injectable purely so the logic is unit-testable; callers pass
  /// nothing and get the real clock.
  Future<void> recordCompletedSession({DateTime? now}) async {
    final current = state.valueOrNull ?? const FocusStats();
    final today = _dayKey(now ?? DateTime.now());
    final yesterday =
        _dayKey((now ?? DateTime.now()).subtract(const Duration(days: 1)));

    late FocusStats next;
    if (current.lastSessionDay == today) {
      next = current.copyWith(
        sessionsOnLastDay: current.sessionsOnLastDay + 1,
        totalSessions: current.totalSessions + 1,
      );
    } else {
      final continues = current.lastSessionDay == yesterday;
      final newStreak = continues ? current.streak + 1 : 1;
      next = current.copyWith(
        sessionsOnLastDay: 1,
        totalSessions: current.totalSessions + 1,
        streak: newStreak,
        longestStreak:
            newStreak > current.longestStreak ? newStreak : current.longestStreak,
        lastSessionDay: today,
      );
    }

    state = AsyncData(next);
    await _saveCurrent();
  }

  Future<void> setDailyGoal(int goal) async {
    final current = state.valueOrNull ?? const FocusStats();
    final next = current.copyWith(dailyGoal: goal.clamp(1, 12));
    state = AsyncData(next);
    await _saveCurrent();
  }

  /// Serialized persistence (same rationale as TasksNotifier): chained
  /// writes that save the CURRENT state, so rapid successive updates can
  /// never persist out of order.
  Future<void> _saveQueue = Future.value();

  Future<void> _saveCurrent() {
    _saveQueue = _saveQueue.then((_) async {
      final stats = state.valueOrNull;
      if (stats != null) await _repo.save(stats);
    });
    return _saveQueue;
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, FocusStats>(
  StatsNotifier.new,
);

/// Date-resolved view for the UI. Recomputed against the current clock each
/// read so a broken streak shows as zero without a write.
final statsViewProvider = Provider<FocusStatsView>((ref) {
  final stats = ref.watch(statsProvider).valueOrNull ?? const FocusStats();
  return FocusStatsView(stats, DateTime.now());
});
