import '../l10n/app_localizations.dart';

/// Cervical mucus / fluid consistency, a fertility signal.
enum CervicalMucusType { dry, sticky, creamy, watery, eggwhite }

/// Localized label for a [CervicalMucusType].
String cervicalMucusLabel(AppLocalizations l10n, CervicalMucusType type) =>
    switch (type) {
      CervicalMucusType.dry => l10n.mucusDry,
      CervicalMucusType.sticky => l10n.mucusSticky,
      CervicalMucusType.creamy => l10n.mucusCreamy,
      CervicalMucusType.watery => l10n.mucusWatery,
      CervicalMucusType.eggwhite => l10n.mucusEggwhite,
    };
