/// What the app is primarily tracking for the user.
enum TrackingMode {
  /// Standard menstrual cycle tracking (default).
  cycle,

  /// Pregnancy: weeks/trimester based tracking.
  pregnancy,

  /// Perimenopause: symptom focused tracking.
  perimenopause,
}

/// Localized (English) label for a [TrackingMode].
String trackingModeLabel(TrackingMode mode) => switch (mode) {
      TrackingMode.cycle => 'Cycle tracking',
      TrackingMode.pregnancy => 'Pregnancy',
      TrackingMode.perimenopause => 'Perimenopause',
    };

/// Short description shown in the settings picker.
String trackingModeDescription(TrackingMode mode) => switch (mode) {
      TrackingMode.cycle => 'Periods, fertility and cycle predictions.',
      TrackingMode.pregnancy => 'Track weeks, trimester and due date.',
      TrackingMode.perimenopause => 'Symptom-focused tracking for this stage.',
    };