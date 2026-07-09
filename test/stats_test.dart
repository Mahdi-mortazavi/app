import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/data/models/focus_stats.dart';
import 'package:app/data/repositories/stats_repository.dart';
import 'package:app/providers/stats_provider.dart';

class _FakeStatsRepository implements StatsRepository {
  FocusStats stored = const FocusStats();

  @override
  Future<FocusStats> load() async => stored;

  @override
  Future<void> save(FocusStats stats) async => stored = stats;
}

void main() {
  late ProviderContainer container;
  late _FakeStatsRepository repo;

  setUp(() async {
    repo = _FakeStatsRepository();
    container = ProviderContainer(
      overrides: [statsRepositoryProvider.overrideWithValue(repo)],
    );
    // Ensure the AsyncNotifier has finished its initial build.
    await container.read(statsProvider.future);
  });

  tearDown(() => container.dispose());

  StatsNotifier notifier() => container.read(statsProvider.notifier);
  FocusStats current() => container.read(statsProvider).value!;

  test('first session starts a streak of 1', () async {
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 10));
    final s = current();
    expect(s.streak, 1);
    expect(s.sessionsOnLastDay, 1);
    expect(s.totalSessions, 1);
    expect(s.longestStreak, 1);
  });

  test('two sessions same day do not advance the streak', () async {
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 9));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 15));
    final s = current();
    expect(s.streak, 1);
    expect(s.sessionsOnLastDay, 2);
    expect(s.totalSessions, 2);
  });

  test('a session the next day continues the chain', () async {
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 9));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 2, 9));
    final s = current();
    expect(s.streak, 2);
    expect(s.sessionsOnLastDay, 1);
    expect(s.longestStreak, 2);
  });

  test('a missed day restarts the chain at 1', () async {
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 9));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 2, 9));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 5, 9)); // gap
    final s = current();
    expect(s.streak, 1);
    expect(s.longestStreak, 2, reason: 'best streak is preserved');
    expect(s.totalSessions, 3);
  });

  test('view resolves a broken streak to zero and today counts to zero',
      () async {
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 9));
    // Three days later, before any new session.
    final view = FocusStatsView(current(), DateTime(2026, 1, 4, 8));
    expect(view.streak, 0, reason: 'chain expired');
    expect(view.sessionsToday, 0);
    expect(view.goalReached, isFalse);
  });

  test('goal progress clamps to the daily goal', () async {
    await notifier().setDailyGoal(2);
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 8));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 10));
    await notifier().recordCompletedSession(now: DateTime(2026, 1, 1, 12));
    final view = FocusStatsView(current(), DateTime(2026, 1, 1, 13));
    expect(view.sessionsToday, 3);
    expect(view.goalProgress, 1.0);
    expect(view.goalReached, isTrue);
  });
}
