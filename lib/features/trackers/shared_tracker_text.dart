import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pregnancy_status.dart';
import '../../models/symptom_insights.dart';
import '../../services/pregnancy_calculator.dart';

/// Shared, accurate plain-language rendering for pregnancy and
/// perimenopause modes.
///
/// All text is generated locally from computed values and curated content;
/// it is educational and not a diagnosis.
abstract class TrackerInsightText {
  static final DateFormat _date = DateFormat('MMMM d, yyyy');

  /// Headline for the pregnancy home card.
  static String pregnancyHeadline(AppLocalizations l10n, PregnancyStatus status) =>
      l10n.trackerPregnantHeadline(status.weeks, status.days);

  /// Summary line including the estimated due date.
  static String pregnancyDueLine(AppLocalizations l10n, PregnancyStatus status) {
    final int daysToGo =
        PregnancyCalculator.kGestationDays - status.totalDays;
    return l10n.trackerDueLine(_date.format(status.dueDate), daysToGo);
  }

  /// Body copy for the current trimester.
  static String pregnancyStageLine(AppLocalizations l10n, PregnancyStatus status) =>
      l10n.trackerStageLine(_trimesterOrdinal(l10n, status.trimester));

  /// Summary for perimenopause from the logged symptom history.
  static String perimenopauseSummary(AppLocalizations l10n, SymptomInsights insights) {
    if (insights.totalLogs == 0) {
      return l10n.trackerPeriEmpty;
    }
    final String top = insights.topSymptoms.isEmpty
        ? '—'
        : insights.topSymptoms.first.symptom;
    return l10n.trackerPeriSummary(insights.totalLogs, top);
  }

  /// Shared educational disclaimer shown in both modes.
  static String disclaimer(AppLocalizations l10n) => l10n.trackerDisclaimer;

  static String _trimesterOrdinal(AppLocalizations l10n, Trimester trimester) =>
      switch (trimester) {
        Trimester.first => l10n.ordinalFirst,
        Trimester.second => l10n.ordinalSecond,
        Trimester.third => l10n.ordinalThird,
      };
}
