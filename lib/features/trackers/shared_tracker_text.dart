import 'package:intl/intl.dart';

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
  static String pregnancyHeadline(PregnancyStatus status) =>
      'You are ${status.weeks} weeks and ${status.days} days pregnant.';

  /// Summary line including the estimated due date.
  static String pregnancyDueLine(PregnancyStatus status) {
    final int daysToGo =
        PregnancyCalculator.kGestationDays - status.totalDays;
    return 'Estimated due date: ${_date.format(status.dueDate)} '
        '($daysToGo days to go based on your dates).';
  }

  /// Body copy for the current trimester.
  static String pregnancyStageLine(PregnancyStatus status) =>
      'You are in the ${_trimesterOrdinal(status.trimester)} trimester.';

  /// Summary for perimenopause from the logged symptom history.
  static String perimenopauseSummary(SymptomInsights insights) {
    if (insights.totalLogs == 0) {
      return 'Log symptoms to see which ones are most frequent for you.';
    }
    final String top = insights.topSymptoms.isEmpty
        ? '—'
        : insights.topSymptoms.first.symptom;
    return 'You have logged symptoms on ${insights.totalLogs} '
        '${insights.totalLogs == 1 ? 'day' : 'days'}. '
        'Your most frequent symptom is "$top".';
  }

  /// Shared educational disclaimer shown in both modes.
  static String disclaimer() =>
      'Witchy is educational and not a diagnostic tool, and is not a method '
      'of contraception. Always consult a qualified healthcare professional '
      'about your health.';

  static String _trimesterOrdinal(Trimester trimester) => switch (trimester) {
        Trimester.first => 'first',
        Trimester.second => 'second',
        Trimester.third => 'third',
      };
}
