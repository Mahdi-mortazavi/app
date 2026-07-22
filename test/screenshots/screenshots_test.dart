// Screenshot renderer — not a regression test.
//
// Run explicitly (excluded from normal CI via --exclude-tags):
//   flutter test --tags=screenshots --update-goldens test/screenshots
//
// The Screenshots workflow (.github/workflows/screenshots.yml) runs this on a
// real Flutter checkout, then copies the rendered PNGs into docs/screenshots/
// for the README. Rendering through the widget tree means every screenshot is
// pixel-true to the shipped code — no emulator, no stale mockups.
@Tags(['screenshots'])
library;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/data/models/task.dart';
import 'package:app/main.dart';
import 'package:app/presentation/navigation.dart';
import 'package:app/presentation/screens/home_screen.dart';

/// Matches FocusStatsView._dayKey so seeded stats read as "today".
String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

final _seedTasks = [
  {
    'id': 1,
    'title': 'مرور فصل سوم زیست‌شناسی',
    'category': 'مطالعه',
    'duration': 45,
    'reminder': null,
    'isPinned': true,
    'isCompleted': false,
    'subtasks': [
      {'id': 's1', 'title': 'خلاصه‌نویسی', 'isCompleted': true},
      {'id': 's2', 'title': 'حل تمرین‌ها', 'isCompleted': false},
    ],
  },
  {
    'id': 2,
    'title': 'تمرین مدیتیشن',
    'category': 'شخصی',
    'duration': 25,
    'reminder': null,
    'isPinned': true,
    'isCompleted': false,
    'subtasks': [],
  },
  {
    'id': 3,
    'title': 'پاسخ به ایمیل‌های کاری',
    'category': 'کاری',
    'duration': 25,
    'reminder': null,
    'isPinned': false,
    'isCompleted': false,
    'subtasks': [],
  },
  {
    'id': 4,
    'title': 'خرید هفتگی خانه',
    'category': 'خرید',
    'duration': 25,
    'reminder': null,
    'isPinned': false,
    'isCompleted': false,
    'subtasks': [
      {'id': 's3', 'title': 'میوه و سبزیجات', 'isCompleted': false},
    ],
  },
  {
    'id': 5,
    'title': 'ورزش صبحگاهی',
    'category': 'شخصی',
    'duration': 25,
    'reminder': null,
    'isPinned': false,
    'isCompleted': true,
    'subtasks': [],
  },
];

Map<String, Object> _seedPrefs() => {
      'ive_tasks_final_v6': jsonEncode(_seedTasks),
      'nava_focus_stats_v1': jsonEncode({
        'totalSessions': 42,
        'sessionsOnLastDay': 2,
        'streak': 6,
        'longestStreak': 9,
        'lastSessionDay': _dayKey(DateTime.now()),
        'dailyGoal': 3,
      }),
    };

/// Loads every real font so screenshots don't render in the blocky Ahem
/// test font: icon fonts from the FontManifest, text fonts from the bundled
/// assets/google_fonts files (runtime fetching stays off).
Future<void> _loadFonts() async {
  final manifest = jsonDecode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final family = entry['family'] as String;
    // Package fonts (e.g. packages/cupertino_icons/CupertinoIcons) must be
    // registered under both the prefixed and bare family names.
    for (final name in {family, family.split('/').last}) {
      final loader = FontLoader(name);
      for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
        loader.addFont(rootBundle.load(font['asset'] as String));
      }
      await loader.load();
    }
  }
  await GoogleFonts.pendingFonts([
    GoogleFonts.vazirmatn(fontWeight: FontWeight.w300),
    GoogleFonts.vazirmatn(),
    GoogleFonts.vazirmatn(fontWeight: FontWeight.w500),
    GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
    GoogleFonts.vazirmatn(fontWeight: FontWeight.w700),
    GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
  ]);
}

void _sizeAsPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1179, 2556); // iPhone-class canvas
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(_seedPrefs());
  await tester.pumpWidget(const ProviderScope(child: NavaApp()));
  await tester.pumpAndSettle();
}

/// Shadows are stubbed out by the test framework; screenshots need the real
/// ones during pumping AND painting. The flag must be restored before the
/// test body returns (the framework verifies painting debug variables at
/// test end — a tearDown runs too late), hence the wrapper.
Future<void> _withRealShadows(Future<void> Function() body) async {
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(_loadFonts);

  testWidgets('home — light', (tester) async {
    await _withRealShadows(() async {
      _sizeAsPhone(tester);
      await _pumpApp(tester);
      await expectLater(
        find.byType(NavaApp),
        matchesGoldenFile('goldens/home-light.png'),
      );
    });
  });

  testWidgets('home — dark', (tester) async {
    await _withRealShadows(() async {
      _sizeAsPhone(tester);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await _pumpApp(tester);
      await expectLater(
        find.byType(NavaApp),
        matchesGoldenFile('goldens/home-dark.png'),
      );
    });
  });

  testWidgets('task form sheet', (tester) async {
    await _withRealShadows(() async {
      _sizeAsPhone(tester);
      await _pumpApp(tester);
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(NavaApp),
        matchesGoldenFile('goldens/task-form.png'),
      );
    });
  });

  testWidgets('focus session', (tester) async {
    await _withRealShadows(() async {
      _sizeAsPhone(tester);
      await _pumpApp(tester);

      final task = Task.fromJson(_seedTasks.first);
      openFocusPage(tester.element(find.byType(HomeScreen)), task);
      // The countdown ticks every second, so pumpAndSettle would never
      // settle — pump past the fade transition (the session starts in a
      // post-frame callback) and the ring's initial sweep instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 950));

      await expectLater(
        find.byType(NavaApp),
        matchesGoldenFile('goldens/focus.png'),
      );

      // Close the session the way a user would (pop the route) so FocusPage
      // disposes in normal order, then pump past the reverse transition +
      // the microtask-deferred stop() so the periodic ticker is cancelled
      // before the test ends.
      await tester.tap(find.byIcon(CupertinoIcons.xmark));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
    });
  });
}
