import '../l10n/app_localizations.dart';

/// The four phases of the menstrual cycle.
enum CyclePhase { menstruation, follicular, ovulatory, luteal }

/// Localized label for a [CyclePhase].
String cyclePhaseLabel(AppLocalizations l10n, CyclePhase phase) =>
    switch (phase) {
      CyclePhase.menstruation => l10n.phaseMenstruation,
      CyclePhase.follicular => l10n.phaseFollicular,
      CyclePhase.ovulatory => l10n.phaseOvulation,
      CyclePhase.luteal => l10n.phaseLuteal,
    };
