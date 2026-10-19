import 'package:intl/intl.dart';

/// Single source of truth for the date strings the UI shows.
///
/// Each screen used to build its own `DateFormat(...)` literal, and the same
/// kind of value drifted between screens (`MMM d, yyyy` in one place,
/// `MMMM d, yyyy` in another). Keeping the patterns here means a wording change
/// is one edit, and tests can assert against the same helper the UI uses.
abstract final class AppDate {
  /// September 10, 2026
  static String long(DateTime d) => DateFormat('MMMM d, yyyy').format(d);

  /// September 10
  static String monthDay(DateTime d) => DateFormat('MMMM d').format(d);

  /// Sep 10
  static String short(DateTime d) => DateFormat('MMM d').format(d);

  /// Sep 10, 2026
  static String shortYear(DateTime d) => DateFormat('MMM d, yyyy').format(d);

  /// 10 Sep
  static String dayMonth(DateTime d) => DateFormat('d MMM').format(d);

  /// 10 Sep 2026
  static String dayMonthYear(DateTime d) => DateFormat('d MMM yyyy').format(d);

  /// September 2026
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);

  /// Sep
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);

  /// Thursday, September 10
  static String weekdayLong(DateTime d) => DateFormat('EEEE, MMMM d').format(d);

  /// Thursday, Sep 10
  static String weekdayShort(DateTime d) => DateFormat('EEEE, MMM d').format(d);

  /// Sep 10 - Sep 16
  static String range(DateTime from, DateTime to) => '${short(from)} – ${short(to)}';
}
