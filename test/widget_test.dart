import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Home screen renders the empty state with no tasks', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: NavaApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('کارها'), findsOneWidget);
    expect(find.text('هنوز کاری نداری'), findsOneWidget);
  });
}
