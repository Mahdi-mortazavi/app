import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/core/service_locator.dart' as di;
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/pages/home_page.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';
import 'package:app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await di.sl<NotificationService>().init();
  runApp(const IveApp());
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
        home: const HomePage(),
      ),
    );
  }
}
