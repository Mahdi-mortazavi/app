/// Formatting helpers. The app's UI is Persian/RTL, so numbers shown to the
/// user (timer, counts, reminder times) should use Persian digits for visual
/// consistency with the Jalali date in the header — mixing Latin and Persian
/// numerals in one RTL screen reads as unfinished.
class Fmt {
  const Fmt._();

  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  /// Converts every ASCII digit in [input] to its Persian equivalent.
  static String fa(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(_persianDigits[rune - 0x30]);
      } else {
        buffer.write(String.fromCharCode(rune));
      }
    }
    return buffer.toString();
  }

  /// `mm:ss`, zero-padded, Persian digits. Used by the focus timer.
  static String clock(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return fa('$m:$s');
  }

  /// `HH:mm`, both fields zero-padded, Persian digits. Used for reminders.
  static String timeOfDay(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return fa('$h:$m');
  }
}
