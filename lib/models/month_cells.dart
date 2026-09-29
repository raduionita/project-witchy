import 'calendar_day_cell.dart';

class MonthCells {
  const MonthCells({required this.month, required this.cells});

  final DateTime month;

  /// Always 42 cells (6 weeks × 7 days), Monday-first.
  final List<CalendarDayCell> cells;

  CalendarDayCell? cellFor(int day) {
    for (final cell in cells) {
      if (cell.day == day && cell.inMonth) return cell;
    }
    return null;
  }
}
