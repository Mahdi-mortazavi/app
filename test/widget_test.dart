import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:app/core/service_locator.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // We need to initialize the service locator for the app to run
    await di.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const IveApp());
    await tester.pumpAndSettle();

    // Basic verification: look for some text that should be on the home page.
    // Assuming 'کارها' is a common title.
    expect(find.text('کارها'), findsWidgets);
  });
}
