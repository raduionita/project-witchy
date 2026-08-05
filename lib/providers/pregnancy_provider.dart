import '../models/user_settings.dart';
import '../services/pregnancy_service.dart';
import '../services/period_tracking_service.dart';

class PregnancyProvider {
  late final PregnancyService _pregnancyService;

  PregnancyProvider(PeriodTrackingService periodService) {
    _pregnancyService = PregnancyService(periodService);
  }

  String? calculateDueDate({DateTime? lastPeriodDate, UserSettings? settings}) {
    return _pregnancyService.calculateDueDate(lastPeriodDate: lastPeriodDate, settings: settings);
  }

  int getWeekNumber({String? dueDateIso}) {
    return _pregnancyService.getWeekNumber(dueDateIso: dueDateIso);
  }

  String get trimester => _pregnancyService.trimester;

  double get progressPercentage => _pregnancyService.progressPercentage;

  String getDescriptionForWeek(int week) {
    return _pregnancyService.getDescriptionForWeek(week);
  }

  List<Map<String, dynamic>> getWeeklyMilestones() {
    return _pregnancyService.getWeeklyMilestones();
  }
}
