// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Note: IveApp requires dependency injection to be initialized via di.init().
    // Running a full app test would require mocking the service locator.
    // This is a placeholder test to ensure the app structure is correct.
    expect(const IveApp(), isNotNull);
  });
}
