import 'package.flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/core/service_locator.dart' as di;
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/pages/home_page.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/task_management/presentation/pages/focus_page.dart';
import 'package:app/features/task_management/domain/entities/task.dart';

// Global navigator key for deep linking from notifications
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // Initialize notification service with deep linking callback
  await di.sl<NotificationService>().init(
    onNotificationTapped: (taskId) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Find the task by ID and navigate to the focus page
        final state = context.read<TasksBloc>().state;
        if (state is TasksLoadSuccess) {
          try {
            final task = state.tasks.firstWhere((t) => t.id == taskId);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FocusPage(task: task)),
            );
          } catch (e) {
            // If task not found, navigate home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        }
      }
    },
  );

  runApp(const IveApp());
}

class IveApp extends StatelessWidget {
  const IveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<TasksBloc>()..add(LoadTasks()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Nava',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppTheme.background,
          primaryColor: AppTheme.blue,
          fontFamily: GoogleFonts.vazirmatn().fontFamily,
        ),
        home: const HomePage(),
      ),
    );
  }
}
