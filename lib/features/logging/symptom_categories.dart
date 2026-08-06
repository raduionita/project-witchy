/// A named group of related symptoms shown as category sections in logging.
class SymptomCategory {
  const SymptomCategory(this.name, this.symptoms);

  /// Human-readable category label (e.g. "Pain & discomfort").
  final String name;

  /// Symptom names that belong to this category.
  final List<String> symptoms;
}

/// The full symptom catalogue grouped by category.
///
/// This is the source of truth for the logging flow (Phase 4.1 categorised
/// symptom picking) and for [kCommonSymptoms], keeping the flat list in the
/// same relative order as the grouped display.
const List<SymptomCategory> kSymptomCategories = <SymptomCategory>[
  SymptomCategory('Pain & discomfort', <String>[
    'Cramps',
    'Headache',
    'Back pain',
  ]),
  SymptomCategory('Digestive', <String>['Bloating', 'Nausea']),
  SymptomCategory('Breast & skin', <String>['Tender breasts', 'Acne']),
  SymptomCategory('Energy & mood', <String>['Fatigue']),
];

/// Flattened list of every suggested symptom in display order and unique.
final List<String> kCommonSymptoms = <String>[
  for (final SymptomCategory category in kSymptomCategories) ...category.symptoms,
];