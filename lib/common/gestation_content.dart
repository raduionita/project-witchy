import '../models/gestation_week.dart';

abstract final class GestationContent {
  /// Week-range content buckets covering gestational weeks 0-40.
  static const weeks = <GestationWeek>[
    GestationWeek(
      startWeek: 0,
      endWeek: 3,
      size: 'Poppy Seed',
      development: 'A poppy seed of new life has implanted. The neural tube and a primitive heart are beginning to form.',
      tip: 'Start prenatal vitamins with folate and rest whenever your body asks.',
    ),
    GestationWeek(
      startWeek: 4,
      endWeek: 7,
      size: 'Sesame Seed',
      development: 'Now a sesame seed, tiny arm and leg buds stretch out while the heart beats faster each day.',
      tip: 'Nausea may visit - keep plain crackers and water within reach.',
    ),
    GestationWeek(
      startWeek: 8,
      endWeek: 11,
      size: 'Lime Size',
      development: 'Your little spirit matches a ripe Lime. Organs are fully formed and commencing magical function, and fingers and toes are separating.',
      tip: 'First-trimester tiredness is shifting. Elevate iron with spinach potions and speak soft mantras.',
    ),
    GestationWeek(
      startWeek: 12,
      endWeek: 15,
      size: 'Apple Size',
      development: 'About a ripe Apple now, facial features sharpen and your little spirit can squint and frown.',
      tip: 'Energy often returns - gentle walks keep the blood flowing.',
    ),
    GestationWeek(
      startWeek: 16,
      endWeek: 19,
      size: 'Avocado Size',
      development: 'The size of an Avocado, hearing wakes and your little spirit responds to sound and light.',
      tip: 'Sleep on your left side and stay hydrated for the amniotic tide.',
    ),
    GestationWeek(
      startWeek: 20,
      endWeek: 23,
      size: 'Banana Size',
      development: 'About a Banana in length, movement grows stronger and daily routines begin to form.',
      tip: 'Notice movement patterns - a healthy spirit enjoys routine.',
    ),
    GestationWeek(
      startWeek: 24,
      endWeek: 27,
      size: 'Cauliflower Size',
      development: 'Roughly a Cauliflower, lungs branch out and taste buds form while hearing is fully established.',
      tip: 'Practice slow birth breathing and keep glucose screenings booked.',
    ),
    GestationWeek(
      startWeek: 28,
      endWeek: 31,
      size: 'Eggplant Size',
      development: 'An Eggplant now, brain tissue expands fast and the eyes can track a glowing beam.',
      tip: 'Rest with hips elevated and count kicks each evening.',
    ),
    GestationWeek(
      startWeek: 32,
      endWeek: 35,
      size: 'Honeydew Size',
      development: 'About a Honeydew Melon, fat layers smooth the skin as your little spirit settles head-down.',
      tip: 'Pack the birth bag and freeze a few easy meals.',
    ),
    GestationWeek(
      startWeek: 36,
      endWeek: 40,
      size: 'Watermelon Size',
      development: 'A Watermelon at full term, organs mature and the body prepares for the outside world.',
      tip: 'Watch for contractions and keep your birth plan flexible.',
    ),
  ];

  /// Trimester fallback for weeks past the table (or any unmatched value).
  static const _pastTerm = GestationWeek(
    startWeek: 41,
    endWeek: 99,
    size: 'Full Term',
    development: 'Your little spirit has passed 40 weeks and is ready to arrive whenever the portal opens.',
    tip: 'Keep in close contact with your care team and watch for labor signs.',
  );

  static GestationWeek forWeek(int week) {
    if (week < weeks.first.startWeek) return weeks.first;
    for (final entry in weeks) {
      if (entry.covers(week)) return entry;
    }
    return _pastTerm;
  }
}
