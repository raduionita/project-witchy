import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return DateFormat.EEEE().format(date);
  }

  static String formatTime(String time) {
    return time;
  }

  static DateTime getStartOfWeek(DateTime date, {String startDay = 'monday'}) {
    final dayOfWeek = date.weekday;
    int daysToSubtract;

    if (startDay == 'sunday') {
      daysToSubtract = dayOfWeek == 7 ? 0 : dayOfWeek + 1;
    } else {
      daysToSubtract = dayOfWeek - 1;
    }

    return date.subtract(Duration(days: daysToSubtract));
  }

  static DateTime getEndOfWeek(DateTime date, {String startDay = 'monday'}) {
    return getStartOfWeek(date, startDay: startDay).add(const Duration(days: 6));
  }

  static List<DateTime> getDaysInMonth(DateTime month, {String startDay = 'monday'}) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final days = <DateTime>[];
    final startOffset = firstDay.weekday;

    for (var i = 0; i < startOffset; i++) {
      days.add(firstDay.subtract(Duration(days: startOffset - i)));
    }

    for (var i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    for (var i = 1; i <= 7; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }

    return days;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static String getMonthName(DateTime date, {bool abbreviated = false}) {
    return abbreviated ? DateFormat.MMM().format(date) : DateFormat.MMMM().format(date);
  }
}
