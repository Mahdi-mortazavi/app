import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/focus_stats.dart';

abstract class StatsRepository {
  Future<FocusStats> load();
  Future<void> save(FocusStats stats);
}

class SharedPreferencesStatsRepository implements StatsRepository {
  static const _storageKey = 'nava_focus_stats_v1';

  @override
  Future<FocusStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const FocusStats();
    return FocusStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(FocusStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(stats.toJson()));
  }
}
