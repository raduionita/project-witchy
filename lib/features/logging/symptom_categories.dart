import '../../l10n/app_localizations.dart';

/// A named group of related symptoms shown as category sections in logging.
class SymptomCategory {
  const SymptomCategory(this.name, this.symptoms);

  /// Human-readable category label (e.g. "Pain & discomfort").
  final String name;

  /// Symptom names that belong to this category.
  final List<String> symptoms;
}

/// The full symptom catalogue grouped by category, localized via [l10n].
///
/// This is the source of truth for the logging flow (Phase 4.1 categorised
/// symptom picking) and for [kCommonSymptoms], keeping the flat list in the
/// same relative order as the grouped display.
List<SymptomCategory> kSymptomCategories(AppLocalizations l10n) =>
    <SymptomCategory>[
      SymptomCategory(l10n.symptomCategoryPain, <String>[
        l10n.symptomCramps,
        l10n.symptomHeadache,
        l10n.symptomBackPain,
      ]),
      SymptomCategory(l10n.symptomCategoryDigestive,
          <String>[l10n.symptomBloating, l10n.symptomNausea]),
      SymptomCategory(l10n.symptomCategoryBreastSkin,
          <String>[l10n.symptomTenderBreasts, l10n.symptomAcne]),
      SymptomCategory(
          l10n.symptomCategoryEnergyMood, <String>[l10n.symptomFatigue]),
    ];

/// Flattened list of every suggested symptom in display order and unique.
List<String> kCommonSymptoms(AppLocalizations l10n) => <String>[
      for (final SymptomCategory category in kSymptomCategories(l10n))
        ...category.symptoms,
    ];
