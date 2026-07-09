import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'providers/task_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Notifications need timezone data loaded before any reminder can be
  // scheduled, so this awaits before the first frame rather than racing it.
  // A failure here (e.g. a plugin/platform hiccup) must never block launch —
  // the app is fully usable without notifications, so we degrade gracefully.
  final container = ProviderContainer();
  try {
    await container.read(notificationServiceProvider).init();
  } catch (e, stack) {
    debugPrint('Notification init failed, continuing without it: $e\n$stack');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NavaApp(),
    ),
  );
}

class NavaApp extends StatelessWidget {
  const NavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nava',
      theme: AppTheme.light,
      builder: (context, child) {
        // Honor the system Dynamic Type setting, but clamp the upper bound so
        // the largest accessibility sizes scale text without shattering the
        // glass layouts (which have fixed-height rows and pinned cards).
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.35,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
