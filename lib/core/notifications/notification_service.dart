import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps `flutter_local_notifications` + `timezone`. Owns initialization,
/// permission requests, and exact-alarm scheduling with a graceful fallback
/// so a denied "exact alarm" permission (Android 13/14+) degrades to an
/// inexact-but-still-timely reminder instead of throwing.
class NotificationService {
  NotificationService() : _plugin = fln.FlutterLocalNotificationsPlugin();

  final fln.FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channel = fln.AndroidNotificationDetails(
    'focus_channel',
    'Focus Tasks',
    channelDescription: 'Task reminders',
    importance: fln.Importance.max,
    priority: fln.Priority.high,
  );

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();
    try {
      final ianaName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(ianaName));
    } catch (_) {
      // Falls back to whatever tz.local already resolved to (UTC). A
      // reminder still fires at the right wall-clock moment as long as the
      // device's own clock/zone is correct — this only affects DST-edge
      // precision if the IANA lookup itself failed.
    }

    const android = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = fln.DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const fln.InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  /// True if the OS currently reports notification permission as granted.
  /// Callers should show a custom "priming" UI *before* invoking
  /// [requestPermission] — this only reflects current OS state.
  Future<bool> hasPermission() async {
    if (kIsWeb) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        fln.IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.checkPermissions();
      return granted?.isEnabled ?? false;
    }
    return false;
  }

  /// Triggers the native permission prompt. Android 13+ needs
  /// `POST_NOTIFICATIONS`; iOS needs alert/badge/sound. Returns whether it
  /// ended up granted.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        fln.AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        fln.IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Schedules an exact reminder at [time]. If the platform rejects an
  /// exact alarm (missing `SCHEDULE_EXACT_ALARM` on Android 13/14+), retries
  /// once with an inexact-but-still-near-time mode rather than crashing or
  /// silently dropping the reminder.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (kIsWeb || !_initialized) return;
    if (!time.isAfter(DateTime.now())) return;

    final scheduled = tz.TZDateTime.from(time, tz.local);
    final details = const fln.NotificationDetails(
      android: _channel,
      iOS: fln.DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Exact scheduling failed ($e), falling back to inexact.');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              fln.UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e2) {
        debugPrint('Inexact scheduling also failed ($e2).');
      }
    }
  }

  /// Fires immediately — used for a focus-timer completion alert, or to
  /// surface a reminder whose original time was missed while the app was
  /// killed.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      id,
      title,
      body,
      const fln.NotificationDetails(
        android: _channel,
        iOS: fln.DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(id);
  }
}
