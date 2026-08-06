import 'package:flutter/foundation.dart';

/// Which trimester of pregnancy the user is in.
enum Trimester { first, second, third }

/// Computed, read-only pregnancy state for a given reference date.
@immutable
class PregnancyStatus {
  const PregnancyStatus({
    required this.lmp,
    required this.dueDate,
    required this.weeks,
    required this.days,
    required this.trimester,
  });

  /// Last menstrual period (pregnancy start reference).
  final DateTime lmp;

  /// Estimated due date.
  final DateTime dueDate;

  /// Completed gestational weeks.
  final int weeks;

  /// Extra days beyond [weeks].
  final int days;

  final Trimester trimester;

  /// Gestational age in total days.
  int get totalDays => weeks * 7 + days;
}
