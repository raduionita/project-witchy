import '../../l10n/app_localizations.dart';
import '../../models/pregnancy_status.dart';

/// Static, curated pregnancy guidance keyed by trimester.
///
/// Content is educational and general; it never references personal data and
/// does not substitute for professional care.
abstract class PregnancyGuidance {
  /// Human title for a trimester.
  static String trimesterTitle(AppLocalizations l10n, Trimester trimester) =>
      switch (trimester) {
        Trimester.first => l10n.trimesterFirst,
        Trimester.second => l10n.trimesterSecond,
        Trimester.third => l10n.trimesterThird,
      };

  /// One-line description of the stage.
  static String stageSummary(AppLocalizations l10n, Trimester trimester) =>
      switch (trimester) {
        Trimester.first => l10n.stageSummaryFirst,
        Trimester.second => l10n.stageSummarySecond,
        Trimester.third => l10n.stageSummaryThird,
      };

  /// Evidence-informed general tips for the trimester.
  static List<String> tipsFor(AppLocalizations l10n, Trimester trimester) =>
      switch (trimester) {
        Trimester.first => <String>[
            l10n.tipFirst1,
            l10n.tipFirst2,
            l10n.tipFirst3,
          ],
        Trimester.second => <String>[
            l10n.tipSecond1,
            l10n.tipSecond2,
            l10n.tipSecond3,
          ],
        Trimester.third => <String>[
            l10n.tipThird1,
            l10n.tipThird2,
            l10n.tipThird3,
          ],
      };

  /// Week-by-week headline for [weeks], or null outside the 0–40 range.
  static String? weekHeadline(AppLocalizations l10n, int weeks) {
    if (weeks < 0 || weeks > kGestationWeeks) return null;
    if (weeks <= 4) return l10n.weekHeadlineEarly;
    if (weeks <= 12) return l10n.weekHeadlineFirst;
    if (weeks <= 26) return l10n.weekHeadlineSecond;
    return l10n.weekHeadlineThird;
  }
}

/// Max gestational weeks used by [PregnancyGuidance.weekHeadline].
const int kGestationWeeks = 40;
