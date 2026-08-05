/// Date utility functions for cycle calculations.
library;

import 'package:intl/intl.dart';

/// Calculates the current cycle day given a period start date and today.
int calculateCycleDay(DateTime periodStart) {
  final now = DateTime.now();
  return (now.difference(periodStart).inDays + 1);
}

/// Estimates the next period start date based on cycle length and last known start.
DateTime? getNextPeriodDate(DateTime lastPeriodStart, int cycleLength) {
  return lastPeriodStart.add(Duration(days: cycleLength));
}

/// Calculates the number of days until the next expected period.
int? getDaysUntilNextPeriod(DateTime lastPeriodStart, int cycleLength) {
  final next = getNextPeriodDate(lastPeriodStart, cycleLength);
  if (next == null) return null;

  final now = DateTime.now();
  if (next.isBefore(now)) {
    return null; // Period already started or overdue
  }
  return next.difference(now).inDays;
}

/// Estimates the ovulation date given a cycle length.
DateTime? getOvulationDate(DateTime lastPeriodStart, int cycleLength) {
  final next = getNextPeriodDate(lastPeriodStart, cycleLength);
  if (next == null) return null;

  return next.subtract(const Duration(days: 14));
}

/// Returns the fertile window (start and end) given a cycle length.
(DateTime, DateTime)? getFertileWindow(
  DateTime lastPeriodStart,
  int cycleLength,
) {
  final ovulation = getOvulationDate(lastPeriodStart, cycleLength);
  if (ovulation == null) return (DateTime.now(), DateTime.now());

  final start = ovulation.subtract(const Duration(days: 5));
  final end = ovulation.add(const Duration(days: 1));
  return (start, end);
}

/// Formats a date as a short month-day string (e.g., "Jan 15").
String formatShortDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}

/// Formats a date as a weekday + month-day string (e.g., "Mon, Jan 15").
String formatDayDate(DateTime date) {
  return DateFormat('EEEE, MMM d').format(date);
}

/// Formats a date as year-month-day (ISO-like).
String formatIsoDate(DateTime date) {
  return DateFormat.yMd().format(date);
}

/// Gets the month name for a given date.
String formatMonthName(DateTime date) {
  return DateFormat('MMMM').format(date);
}

/// Checks if a date falls within a given range (inclusive).
bool isDateInRange(DateTime date, DateTime start, DateTime end) {
  return !date.isBefore(start) && !date.isAfter(end);
}
