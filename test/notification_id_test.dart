import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/notifications/notification_service.dart';

void main() {
  group('NotificationService.safeId', () {
    const maxInt32 = 2147483647;

    test('maps a millisecond-epoch task id into 32-bit range', () {
      // A realistic task id (DateTime.now().millisecondsSinceEpoch).
      final id = NotificationService.safeId(1783574843719);
      expect(id, inInclusiveRange(0, maxInt32 - 1));
    });

    test('is deterministic — same source always maps to the same id', () {
      const source = 1783574843719 + 900000; // focus-session style id
      expect(
        NotificationService.safeId(source),
        NotificationService.safeId(source),
      );
    });

    test('never returns a negative id', () {
      for (final source in [0, 1, -5, maxInt32, 1783574843719, 1 << 62]) {
        expect(NotificationService.safeId(source), greaterThanOrEqualTo(0));
      }
    });

    test('keeps small ids unchanged', () {
      expect(NotificationService.safeId(42), 42);
    });
  });
}
