/// Persisted momentum data behind the behavioral-science features.
///
/// Stores only raw facts; "today's" derived values (which depend on the
/// current date) are computed in [FocusStatsView] so the stored data never
/// goes stale between days.
class FocusStats {
  const FocusStats({
    this.totalSessions = 0,
    this.sessionsOnLastDay = 0,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastSessionDay,
    this.dailyGoal = 3,
  });

  /// Lifetime completed focus sessions.
  final int totalSessions;

  /// Sessions completed on [lastSessionDay] specifically.
  final int sessionsOnLastDay;

  /// Consecutive days (ending on [lastSessionDay]) with at least one session.
  final int streak;

  final int longestStreak;

  /// Day-key ("y-m-d") of the most recent completed session, or null if none.
  final String? lastSessionDay;

  /// User's target sessions per day (goal-gradient target).
  final int dailyGoal;

  FocusStats copyWith({
    int? totalSessions,
    int? sessionsOnLastDay,
    int? streak,
    int? longestStreak,
    String? lastSessionDay,
    int? dailyGoal,
  }) {
    return FocusStats(
      totalSessions: totalSessions ?? this.totalSessions,
      sessionsOnLastDay: sessionsOnLastDay ?? this.sessionsOnLastDay,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastSessionDay: lastSessionDay ?? this.lastSessionDay,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalSessions': totalSessions,
        'sessionsOnLastDay': sessionsOnLastDay,
        'streak': streak,
        'longestStreak': longestStreak,
        'lastSessionDay': lastSessionDay,
        'dailyGoal': dailyGoal,
      };

  factory FocusStats.fromJson(Map<String, dynamic> json) => FocusStats(
        totalSessions: json['totalSessions'] as int? ?? 0,
        sessionsOnLastDay: json['sessionsOnLastDay'] as int? ?? 0,
        streak: json['streak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        lastSessionDay: json['lastSessionDay'] as String?,
        dailyGoal: json['dailyGoal'] as int? ?? 3,
      );
}

/// A date-resolved read of [FocusStats]: the values the UI should actually
/// show *today*. Keeping this separate from the stored model means a streak
/// silently expires when a day is missed, without needing a write.
class FocusStatsView {
  FocusStatsView(this._stats, DateTime now)
      : _today = _dayKey(now),
        _yesterday = _dayKey(now.subtract(const Duration(days: 1)));

  final FocusStats _stats;
  final String _today;
  final String _yesterday;

  int get dailyGoal => _stats.dailyGoal;
  int get longestStreak => _stats.longestStreak;
  int get totalSessions => _stats.totalSessions;

  /// Sessions completed *today* — zero on a fresh day even though the stored
  /// `sessionsOnLastDay` still reflects the last active day.
  int get sessionsToday =>
      _stats.lastSessionDay == _today ? _stats.sessionsOnLastDay : 0;

  /// The streak only "counts" if the last session was today or yesterday;
  /// otherwise the chain is broken and shows as zero.
  int get streak {
    if (_stats.lastSessionDay == _today || _stats.lastSessionDay == _yesterday) {
      return _stats.streak;
    }
    return 0;
  }

  /// 0..1 progress toward the daily goal (goal-gradient signal).
  double get goalProgress {
    if (dailyGoal <= 0) return 0;
    return (sessionsToday / dailyGoal).clamp(0.0, 1.0);
  }

  bool get goalReached => sessionsToday >= dailyGoal;

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
