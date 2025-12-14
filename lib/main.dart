import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vibration/vibration.dart';

// ==============================================================================
// 1. DESIGN SYSTEM
// ==============================================================================

class AppDesign {
  static const Color background = Color(0xFFF5F5F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1D1D1F);
  static const Color textSub = Color(0xFF86868B);
  static const Color blue = Color(0xFF0071E3);
  static const Color red = Color(0xFFFF3B30);
  static const Color green = Color(0xFF34C759);
  static const Color orange = Color(0xFFFF9500);
  static const Color purple = Color(0xFFAF52DE);

  static TextStyle get timerFont => GoogleFonts.ibmPlexMono(
        fontSize: 64,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      );

  static TextStyle get titleLarge => GoogleFonts.vazirmatn(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: textMain,
        letterSpacing: -1,
      );

  static TextStyle get body =>
      GoogleFonts.vazirmatn(fontSize: 16, color: textMain, height: 1.5);

  static BorderRadius radius = BorderRadius.circular(24);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

// ==============================================================================
// 2. MODELS
// ==============================================================================

class SubTask {
  String id;
  String title;
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false})
      : id = DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) =>
      SubTask(title: json['title'], isCompleted: json['isCompleted'])
        ..id = json['id'] ?? "";
}

class Task {
  int id;
  String title;
  String category;
  int duration;
  DateTime? reminder;
  bool isPinned;
  bool isCompleted;
  List<SubTask> subtasks;
  DateTime? completionDate;

  Task({
    required this.id,
    required this.title,
    this.category = 'شخصی',
    this.duration = 25,
    this.reminder,
    this.isPinned = false,
    this.isCompleted = false,
    List<SubTask>? subtasks,
    this.completionDate,
  }) : subtasks = subtasks ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'duration': duration,
        'reminder': reminder?.toIso8601String(),
        'isPinned': isPinned,
        'isCompleted': isCompleted,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'completionDate': completionDate?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        duration: json['duration'],
        reminder:
            json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
        isPinned: json['isPinned'],
        isCompleted: json['isCompleted'],
        subtasks:
            (json['subtasks'] as List).map((s) => SubTask.fromJson(s)).toList(),
        completionDate: json['completionDate'] != null
            ? DateTime.parse(json['completionDate'])
            : null,
      );
}

// ==============================================================================
// 3. PROVIDER (Logic)
// ==============================================================================

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  final fln.FlutterLocalNotificationsPlugin _notifications =
      fln.FlutterLocalNotificationsPlugin();

  List<Task> get tasks => _tasks;
  List<Task> get pinnedTasks =>
      _tasks.where((t) => t.isPinned && !t.isCompleted).toList();
  List<Task> get activeTasks =>
      _tasks.where((t) => !t.isPinned && !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      _loadData();
      return;
    }

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

    // درخواست دسترسی نوتیفیکیشن برای اندروید ۱۳+
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('ive_tasks_final_v6');
    if (data != null) {
      _tasks = (jsonDecode(data) as List).map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void addTask(Task t) {
    _tasks.insert(0, t);
    _schedule(t);
    _save();
    notifyListeners();
  }

  void updateTask(Task t) {
    int i = _tasks.indexWhere((x) => x.id == t.id);
    if (i != -1) {
      _tasks[i] = t;
      _schedule(t);
      _save();
      notifyListeners();
    }
  }

  void toggleComplete(int id) {
    final t = _tasks.firstWhere((x) => x.id == id);
    t.isCompleted = !t.isCompleted;
    if (t.isCompleted) {
      t.completionDate = DateTime.now();
      if (!kIsWeb) _notifications.cancel(id);
    } else {
      t.completionDate = null;
      _schedule(t);
    }
    _save();
    notifyListeners();
    if (t.isCompleted)
      _vibrateSuccess();
    else
      _vibrateLight();
  }

  void delete(int id) {
    _tasks.removeWhere((x) => x.id == id);
    if (!kIsWeb) _notifications.cancel(id);
    _save();
    notifyListeners();
  }

  void toggleSubTask(int taskId, String subId) {
    final t = _tasks.firstWhere((x) => x.id == taskId);
    final s = t.subtasks.firstWhere((y) => y.id == subId);
    s.isCompleted = !s.isCompleted;
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'ive_tasks_final_v6',
      jsonEncode(_tasks.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _schedule(Task t) async {
    if (kIsWeb) return;
    if (t.reminder != null &&
        !t.isCompleted &&
        t.reminder!.isAfter(DateTime.now())) {
      try {
        // تنظیم دقیق برای نسخه جدید کتابخانه
        await _notifications.zonedSchedule(
          t.id,
          'یادآوری',
          t.title,
          tz.TZDateTime.from(t.reminder!, tz.local),
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
          // پارامترهای نسخه ۱۸+
          androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              fln.UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint("Scheduling Error: $e");
      }
    }
  }

  void _vibrateLight() {
    if (kIsWeb) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 15);
    });
  }

  void _vibrateSuccess() {
    if (kIsWeb) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(pattern: [0, 50, 100, 50]);
    });
  }
}

// ==============================================================================
// 4. MAIN & UI
// ==============================================================================

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
      child: const IveApp(),
    ),
  );
}

class IveApp extends StatelessWidget {
  const IveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<TasksBloc>()..add(LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nava',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.background,
          primaryColor: AppTheme.blue,
          fontFamily: GoogleFonts.vazirmatn().fontFamily,
        ),
      ),
    );
  }
}
