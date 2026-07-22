import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'providers/task_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      darkTheme: AppTheme.dark,
      builder: (context, child) {
        // Honor the system Dynamic Type setting, but clamp the upper bound so
        // the largest accessibility sizes scale text without shattering the
        // glass layouts (which have fixed-height rows and pinned cards).
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.35,
        );
        final isDark = mq.platformBrightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          // Status/navigation bar icons flip with appearance; the bar itself
          // stays transparent over the canvas gradient.
          value: (isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: MediaQuery(
            data: mq.copyWith(textScaler: clamped),
            // The screens draw on the custom glass canvas instead of a
            // Scaffold, so without this transparent Material there is no
            // DefaultTextStyle: raw-styled Text falls back to the platform
            // font (not Vazirmatn) with the "missing Material" yellow
            // underlines.
            child: Material(
              type: MaterialType.transparency,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
