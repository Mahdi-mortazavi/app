import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Abstract class defining the notification service interface
abstract class NotificationService {
  Future<void> init({
    required Function(int) onNotificationTapped,
  });
  Future<bool> requestPermission();
  Future<void> scheduleNotification(Task task);
  Future<void> cancelNotification(int id);
}

// Implementation of the notification service
class NotificationServiceImpl implements NotificationService {
  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  @override
  Future<void> init({
    required Function(int) onNotificationTapped,
  }) async {
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
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final taskId = int.tryParse(response.payload!);
          if (taskId != null) {
            onNotificationTapped(taskId);
          }
        }
      },
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;

      // Request notification permission for Android 13+
      if (deviceInfo.version.sdkInt >= 33) {
        var status = await Permission.notification.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Request exact alarm permission for Android 12+
      if (deviceInfo.version.sdkInt >= 31) {
        var status = await Permission.scheduleExactAlarm.request();
        // It's okay if this is not granted, we have a fallback
      }
    }
    // For iOS, permission is requested during init, and we don't have exact alarm scheduling
    return true;
  }

  @override
  Future<void> scheduleNotification(Task task) async {
    if (kIsWeb) return;
    if (task.reminder != null &&
        !task.isCompleted &&
        task.reminder!.isAfter(DateTime.now())) {

      final bool hasExactAlarmPermission = await Permission.scheduleExactAlarm.isGranted;

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
          payload: task.id.toString(), // Add task ID as payload
          androidScheduleMode: hasExactAlarmPermission
              ? fln.AndroidScheduleMode.exactAllowWhileIdle
              : fln.AndroidScheduleMode.inexact,
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
