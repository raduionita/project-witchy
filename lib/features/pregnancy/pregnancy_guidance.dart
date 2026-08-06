import '../../models/pregnancy_status.dart';

/// Static, curated pregnancy guidance keyed by trimester.
///
/// Content is educational and general; it never references personal data and
/// does not substitute for professional care.
abstract class PregnancyGuidance {
  /// Human title for a trimester.
  static String trimesterTitle(Trimester trimester) => switch (trimester) {
        Trimester.first => 'First trimester',
        Trimester.second => 'Second trimester',
        Trimester.third => 'Third trimester',
      };

  /// One-line description of the stage.
  static String stageSummary(Trimester trimester) => switch (trimester) {
        Trimester.first => 'Major organs and systems are forming. Fatigue and '
            'nausea are common.',
        Trimester.second => 'Growth accelerates and many people feel a boost '
            'in energy. Baby movements often begin.',
        Trimester.third => 'The baby grows rapidly and prepares for birth. '
            'Rest and planning ahead matter.',
      };

  /// Evidence-informed general tips for the trimester.
  static List<String> tipsFor(Trimester trimester) => switch (trimester) {
        Trimester.first => const <String>[
            'Take a folic acid supplement (400–800 mcg) if advised by a clinician.',
            'Stay hydrated and eat small, frequent meals if nausea is an issue.',
            'Avoid alcohol, tobacco and unpasteurised foods.',
          ],
        Trimester.second => const <String>[
            'Keep up gentle, regular activity with clinician approval.',
            'Monitor iron levels; iron needs rise as the baby grows.',
            'Note when you first feel movements — tell your care team.',
          ],
        Trimester.third => const <String>[
            'Pack a hospital bag and plan transport ahead of the due date.',
            'Sleep on your side and practise pelvic floor exercises.',
            'Discuss a birth plan and pain-relief options with your care team.',
          ],
      };

  /// Week-by-week headline for [weeks], or null outside the 0–40 range.
  static String? weekHeadline(int weeks) {
    if (weeks < 0 || weeks > kGestationWeeks) return null;
    if (weeks <= 4) return 'Early pregnancy — confirm care early.';
    if (weeks <= 12) return 'First trimester — organs are forming.';
    if (weeks <= 26) return 'Second trimester — growth and movement.';
    return 'Third trimester — preparing for birth.';
  }
}

/// Max gestational weeks used by [PregnancyGuidance.weekHeadline].
const int kGestationWeeks = 40;
