import '../l10n/app_localizations.dart';

/// What the app is primarily tracking for the user.
enum TrackingMode {
  /// Standard menstrual cycle tracking (default).
  cycle,

  /// Pregnancy: weeks/trimester based tracking.
  pregnancy,

  /// Perimenopause: symptom focused tracking.
  perimenopause,
}

/// Localized label for a [TrackingMode].
String trackingModeLabel(AppLocalizations l10n, TrackingMode mode) =>
    switch (mode) {
      TrackingMode.cycle => l10n.trackingModeCycle,
      TrackingMode.pregnancy => l10n.trackingModePregnancy,
      TrackingMode.perimenopause => l10n.trackingModePerimenopause,
    };

/// Short description shown in the settings picker.
String trackingModeDescription(AppLocalizations l10n, TrackingMode mode) =>
    switch (mode) {
      TrackingMode.cycle => l10n.trackingModeCycleDesc,
      TrackingMode.pregnancy => l10n.trackingModePregnancyDesc,
      TrackingMode.perimenopause => l10n.trackingModePerimenopauseDesc,
    };
