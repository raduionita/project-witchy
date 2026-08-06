import '../l10n/app_localizations.dart';

/// How heavy the flow is on a given day.
enum FlowIntensity { light, medium, heavy }

/// Localized label for a [FlowIntensity].
String flowIntensityLabel(AppLocalizations l10n, FlowIntensity intensity) =>
    switch (intensity) {
      FlowIntensity.light => l10n.flowLight,
      FlowIntensity.medium => l10n.flowMedium,
      FlowIntensity.heavy => l10n.flowHeavy,
    };
