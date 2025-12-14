import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:app/features/task_management/domain/entities/task.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleNotification(Task task);
  Future<void> cancelNotification(int id);
}

class NotificationServiceImpl implements NotificationService {
  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const fln.InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  @override
  Future<void> scheduleNotification(Task task) async {
    if (kIsWeb) return;
    if (task.reminder != null &&
        !task.isCompleted &&
        task.reminder!.isAfter(DateTime.now())) {
      try {
        await _notifications.zonedSchedule(
          task.id,
          'یادآوری',
          task.title,
          tz.TZDateTime.from(task.reminder!, tz.local),
          const fln.NotificationDetails(
            android: fln.AndroidNotificationDetails(
              'focus_channel',
              'Focus Tasks',
              channelDescription: 'Task Reminders',
              importance: fln.Importance.max,
              priority: fln.Priority.high,
            ),
            iOS: fln.DarwinNotificationDetails(),
          ),
          androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              fln.UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint("Scheduling Error: $e");
      }
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notifications.cancel(id);
  }
}
