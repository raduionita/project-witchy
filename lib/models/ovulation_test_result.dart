import '../l10n/app_localizations.dart';

/// Result of a urine LH (ovulation) test reader.
enum OvulationTestResult { negative, high, peak }

/// Localized label for an [OvulationTestResult].
String ovulationTestLabel(AppLocalizations l10n, OvulationTestResult result) =>
    switch (result) {
      OvulationTestResult.negative => l10n.lhNegative,
      OvulationTestResult.high => l10n.lhHigh,
      OvulationTestResult.peak => l10n.lhPeak,
    };
