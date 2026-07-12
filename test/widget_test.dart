import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Home renders the empty state with no tasks', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: NavaApp()));
    await tester.pumpAndSettle();

    expect(find.text('کارها'), findsOneWidget);
    expect(find.text('هنوز کاری نداری'), findsOneWidget);
  });

  testWidgets('Home renders a task and the Momentum card without errors',
      (tester) async {
    // Seed one task under the repository's storage key so the app loads it.
    SharedPreferences.setMockInitialValues({
      'ive_tasks_final_v6':
          '[{"id":1,"title":"تمرین تست","category":"شخصی","duration":25,'
              '"reminder":null,"isPinned":false,"isCompleted":false,"subtasks":[]}]',
    });

    await tester.pumpWidget(const ProviderScope(child: NavaApp()));
    await tester.pumpAndSettle();

    // The task itself renders...
    expect(find.text('تمرین تست'), findsOneWidget);
    // ...and the v2 Momentum card appears once there is at least one task.
    expect(find.text('تمرکز امروز'), findsOneWidget);
    // A clean pumpAndSettle above means no exception was thrown building the
    // new v2 widget tree.
    expect(tester.takeException(), isNull);
  });
}
