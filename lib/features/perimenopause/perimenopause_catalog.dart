/// A group of related perimenopause symptoms.
class PerimenopauseCategory {
  const PerimenopauseCategory({required this.title, required this.symptoms});

  final String title;
  final List<String> symptoms;
}

/// Curated perimenopause symptom categories used by the tracker.
///
/// Content is localized (English) and stays on-device; it is informational
/// and not a diagnostic tool.
const List<PerimenopauseCategory> kPerimenopauseCategories = [
  PerimenopauseCategory(
    title: 'Body temperature',
    symptoms: ['Hot flashes', 'Night sweats', 'Chills'],
  ),
  PerimenopauseCategory(
    title: 'Sleep & energy',
    symptoms: ['Trouble sleeping', 'Fatigue', 'Waking at night'],
  ),
  PerimenopauseCategory(
    title: 'Mood & focus',
    symptoms: ['Mood swings', 'Irritability', 'Brain fog', 'Anxiety'],
  ),
  PerimenopauseCategory(
    title: 'Cycle changes',
    symptoms: ['Irregular periods', 'Heavier flow', 'Lighter flow',
        'Missed periods'],
  ),
  PerimenopauseCategory(
    title: 'Other',
    symptoms: ['Vaginal dryness', 'Joint pain', 'Headaches', 'Low libido'],
  ),
];

/// Flattened list of all catalog symptoms (for chips/validation).
List<String> get kAllPerimenopauseSymptoms => <String>[
      for (final PerimenopauseCategory category in kPerimenopauseCategories)
        ...category.symptoms,
    ];
