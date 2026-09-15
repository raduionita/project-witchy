import '../l10n/app_localizations.dart';

/// Result of a home pregnancy test.
enum PregnancyTestResult { negative, positive }

/// Localized label for a [PregnancyTestResult].
String pregnancyTestLabel(AppLocalizations l10n, PregnancyTestResult result) =>
    switch (result) {
      PregnancyTestResult.negative => l10n.testNegative,
      PregnancyTestResult.positive => l10n.testPositive,
    };
