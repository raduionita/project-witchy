import '../models/user_settings.dart';
import 'period_tracking_service.dart';

class PregnancyService {
  final PeriodTrackingService _periodService;

  PregnancyService(this._periodService);

  String? calculateDueDate({DateTime? lastPeriodDate, UserSettings? settings}) {
    final lmpDate = lastPeriodDate ?? _getLastPeriodStartDate(settings: settings);
    if (lmpDate == null) return null;

    final cycleLength = settings?.averageCycleLength ?? _periodService.getAverageCycleLength();
    final dueDate = lmpDate.add(Duration(days: 280 + (cycleLength - 28).toInt()));

    return dueDate.toIso8601String();
  }

  DateTime? _getLastPeriodStartDate({UserSettings? settings}) {
    final cycles = _periodService.cycles.where((c) => c.endDate != null).toList();
    if (cycles.isEmpty) return null;

    return cycles.first.startDate;
  }

  int getWeekNumber({String? dueDateIso}) {
    if (dueDateIso == null) return 0;

    final dueDate = DateTime.parse(dueDateIso);
    final lastPeriod = dueDate.subtract(const Duration(days: 280));
    final now = DateTime.now();

    final weeks = now.difference(lastPeriod).inDays ~/ 7;
    return weeks.clamp(0, 43);
  }

  String get trimester {
    final week = getWeekNumber();
    if (week <= 12) return 'First Trimester (Weeks 1-12)';
    if (week <= 27) return 'Second Trimester (Weeks 13-27)';
    return 'Third Trimester (Weeks 28-40+)';
  }

  double get progressPercentage {
    final week = getWeekNumber();
    return (week / 40.0 * 100.0).clamp(0.0, 100.0);
  }

  String getDescriptionForWeek(int week) {
    if (week <= 4) return 'The fertilized egg is implanting in the uterine wall. Hormone levels are beginning to rise.';
    if (week <= 8) return 'The embryo is developing rapidly. Major organs and body systems are beginning to form.';
    if (week <= 12) return 'The embryo is now a fetus. All major organs are formed and beginning to function.';
    if (week <= 16) return 'The fetus is growing rapidly. You may start to feel movement soon.';
    if (week <= 20) return 'Halfway point! The fetus can hear sounds. You may feel distinct kicks and movement.';
    if (week <= 24) return 'The fetus is developing lungs and eyes. Survival outside the womb becomes increasingly likely.';
    if (week <= 28) return 'The fetus is gaining weight rapidly. Brain development is accelerating.';
    if (week <= 32) return 'The fetus is practicing breathing. Most organs are fully functional.';
    if (week <= 36) return 'The fetus is moving into position for birth. Weight gain continues rapidly.';
    return 'Your baby is fully developed and ready to be born. You may go into labor at any time.';
  }

  List<Map<String, dynamic>> getWeeklyMilestones() {
    return [
      {'week': 4, 'milestone': 'Implantation complete', 'size': 'Poppy seed'},
      {'week': 8, 'milestone': 'All major organs forming', 'size': 'Blueberry'},
      {'week': 12, 'milestone': 'Fetus can make fists', 'size': 'Lime'},
      {'week': 16, 'milestone': 'Fetus can smile', 'size': 'Avocado'},
      {'week': 20, 'milestone': 'Halfway point reached', 'size': 'Banana'},
      {'week': 24, 'milestone': 'Lungs developing', 'size': 'Corn cob'},
      {'week': 28, 'milestone': 'Eyes can open', 'size': 'Eggplant'},
      {'week': 32, 'milestone': 'Bone development complete', 'size': 'Cabbage'},
      {'week': 36, 'milestone': 'Moving into position', 'size': 'Cantaloupe'},
      {'week': 40, 'milestone': 'Fully developed', 'size': 'Watermelon'},
    ];
  }
}
