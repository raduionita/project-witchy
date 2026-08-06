import '../../l10n/app_localizations.dart';

/// A group of related perimenopause symptoms.
class PerimenopauseCategory {
  const PerimenopauseCategory({required this.title, required this.symptoms});

  final String title;
  final List<String> symptoms;
}

/// Curated perimenopause symptom categories used by the tracker.
///
/// Content is localized via [l10n] and stays on-device; it is informational
/// and not a diagnostic tool.
List<PerimenopauseCategory> kPerimenopauseCategories(AppLocalizations l10n) =>
    <PerimenopauseCategory>[
      PerimenopauseCategory(
        title: l10n.periCatBodyTemp,
        symptoms: <String>[
          l10n.periHotFlashes,
          l10n.periNightSweats,
          l10n.periChills,
        ],
      ),
      PerimenopauseCategory(
        title: l10n.periCatSleep,
        symptoms: <String>[
          l10n.periTroubleSleeping,
          l10n.periFatigue,
          l10n.periWakingNight,
        ],
      ),
      PerimenopauseCategory(
        title: l10n.periCatMood,
        symptoms: <String>[
          l10n.periMoodSwings,
          l10n.periIrritability,
          l10n.periBrainFog,
          l10n.periAnxiety,
        ],
      ),
      PerimenopauseCategory(
        title: l10n.periCatCycle,
        symptoms: <String>[
          l10n.periIrregularPeriods,
          l10n.periHeavierFlow,
          l10n.periLighterFlow,
          l10n.periMissedPeriods,
        ],
      ),
      PerimenopauseCategory(
        title: l10n.periCatOther,
        symptoms: <String>[
          l10n.periVaginalDryness,
          l10n.periJointPain,
          l10n.periHeadaches,
          l10n.periLowLibido,
        ],
      ),
    ];

/// Flattened list of all catalog symptoms (for chips/validation).
List<String> kAllPerimenopauseSymptoms(AppLocalizations l10n) => <String>[
      for (final PerimenopauseCategory category in kPerimenopauseCategories(l10n))
        ...category.symptoms,
    ];
