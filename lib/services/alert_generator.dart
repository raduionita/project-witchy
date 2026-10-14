import '../models/alert_item.dart';
import '../models/alert_type.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';

/// Pure alert derivation from cycle + logging state. Each candidate carries a
/// stable id so [AlertProvider] can dedupe across regenerations.
class AlertGenerator {
  AlertGenerator._();

  /// Reference new moon used for the synodic phase calculation.
  static final DateTime newMoonEpoch = DateTime.utc(2000, 1, 6, 18, 14);
  static const double synodicDays = 29.530588853;

  static List<AlertItem> generate({
    required CycleProvider cycle,
    required LoggingProvider logging,
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final out = <AlertItem>[];

    final days = cycle.daysUntilPeriod(today: now);
    if (days == 1 || days == 2) {
      final start = cycle.nextPeriodStart(today: now);
      out.add(
        AlertItem(
          id: 'period-d$days-${_dateKey(start)}',
          type: AlertType.periodPredicted,
          title: 'Period Approaching',
          body:
              'Your period is predicted to begin in $days ${days == 1 ? 'day' : 'days'}. Log symptoms as the days approach.',
          createdAt: now,
          eventDate: start,
        ),
      );
    }

    // Fertility copy follows the same gated cycle logic as the calendar.
    // Peak fires on ovulation day; window-start fires when the fertile range opens.
    if (cycle.showFertilityPredictions) {
      if (cycle.isOvulationDay(today)) {
        out.add(
          AlertItem(
            id: 'fertile-${_dateKey(today)}',
            type: AlertType.fertileWindow,
            title: 'Fertility Window Peak',
            body: cycle.isPerimenopause
                ? 'Your fertility may peak around today. Timing can shift in perimenopause.'
                : 'Your fertility peaks today. High chance of ovulation.',
            createdAt: now,
            eventDate: today,
          ),
        );
      } else if (cycle.isFertileDay(today) && cycle.daysUntilOvulation(today: now) == 2) {
        out.add(
          AlertItem(
            id: 'fertile-start-${_dateKey(today)}',
            type: AlertType.fertileWindow,
            title: 'Fertility Window',
            body: cycle.isPerimenopause
                ? 'Your fertile window may be open today. Timing can shift in perimenopause.'
                : 'Your fertile window opens today. Odds of conception rise over the next few days.',
            createdAt: now,
            eventDate: today,
          ),
        );
      }
    }

    if (now.hour >= 18 && !logging.hasLog(today)) {
      out.add(
        AlertItem(
          id: 'log-${_dateKey(today)}',
          type: AlertType.logMissing,
          title: 'Log Missing',
          body: 'You have not logged today yet. Record flow, mood and symptoms to keep predictions aligned.',
          createdAt: now,
          eventDate: today,
        ),
      );
    }

    final moon = lunarMilestone(now);
    if (moon != null) out.add(moon);

    return out;
  }

  /// New/full moon alert for [now], or null when the moon is neither.
  static AlertItem? lunarMilestone(DateTime now) {
    final days = now.toUtc().difference(newMoonEpoch).inMilliseconds / Duration.millisecondsPerDay;
    final age = days % synodicDays;
    final today = DateTime(now.year, now.month, now.day);

    if (age < 0.5 || age > synodicDays - 0.5) {
      return AlertItem(
        id: 'moon-new-${_dateKey(today)}',
        type: AlertType.lunarMilestone,
        title: 'New Moon',
        body: 'A new moon tonight - a gentle reset for your tracking rhythm.',
        createdAt: now,
        eventDate: today,
      );
    }
    if ((age - synodicDays / 2).abs() < 0.5) {
      return AlertItem(
        id: 'moon-full-${_dateKey(today)}',
        type: AlertType.lunarMilestone,
        title: 'Full Moon',
        body: 'Full moon tonight. A good evening to log symptoms and temperature.',
        createdAt: now,
        eventDate: today,
      );
    }
    return null;
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
