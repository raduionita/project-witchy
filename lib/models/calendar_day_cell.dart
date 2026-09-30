class CalendarDayCell {
  const CalendarDayCell({
    required this.day,
    this.inMonth = true,
    this.cycleDay = 0,
    this.isToday = false,
    this.isPredictedPeriod = false,
    this.isLoggedBleed = false,
    this.isFertile = false,
    this.isOvulation = false,
    this.isLogged = false,
    this.isSelected = false,
  });

  /// Day of month (1–31).
  final int day;
  final bool inMonth;

  /// Projected cycle day (1+); 0 for adjacent-month cells.
  final int cycleDay;
  final bool isToday;
  final bool isPredictedPeriod;
  final bool isLoggedBleed;
  final bool isFertile;
  final bool isOvulation;
  final bool isLogged;
  final bool isSelected;

  const CalendarDayCell.padding() : this(day: 0, inMonth: false);

  bool get isPeriod => isPredictedPeriod || isLoggedBleed;
}
