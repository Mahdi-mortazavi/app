// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/service_locator.dart' as di;

void main() {
  testWidgets('Nava smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await di.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const IveApp());
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    // Verify that our app shows the main title or some key text.
    // 'کارها' is a common Persian word in the app.
    expect(find.text('کارها'), findsWidgets);
  });
}
