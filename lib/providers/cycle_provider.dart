import 'package:flutter/foundation.dart';
import '../models/period_cycle.dart';
import '../models/cycle_prediction.dart';
import '../models/user_settings.dart';
import '../services/period_tracking_service.dart';
import '../services/fertility_service.dart';

class CycleProvider extends ChangeNotifier {
  final PeriodTrackingService _periodService = PeriodTrackingService();
  late final FertilityService _fertilityService;

  CycleProvider() {
    _fertilityService = FertilityService(_periodService);
  }

  List<PeriodCycle> get cycles => _periodService.cycles;

  PeriodCycle? get activePeriod => _periodService.activePeriod;

  void addPeriod({
    required DateTime startDate,
    DateTime? endDate,
    double flowIntensity = 2.0,
    List<Symptom>? symptoms,
    String? notes,
  }) {
    _periodService.addPeriod(
      startDate: startDate,
      endDate: endDate,
      flowIntensity: flowIntensity,
      symptoms: symptoms,
      notes: notes,
    );
    notifyListeners();
  }

  void updatePeriod(PeriodCycle cycle, {DateTime? endDate}) {
    _periodService.updatePeriod(cycle, endDate: endDate);
    notifyListeners();
  }

  void deletePeriod(PeriodCycle cycle) {
    _periodService.deletePeriod(cycle);
    notifyListeners();
  }

  void addSymptom(PeriodCycle cycle, String symptomName, {double severity = 1.0}) {
    _periodService.addSymptom(cycle, symptomName, severity: severity);
    notifyListeners();
  }

  void addMood(PeriodCycle cycle, Mood mood, {String? note}) {
    _periodService.addMood(cycle, mood, note: note);
    notifyListeners();
  }

  void addDischargePattern(PeriodCycle cycle, DischargePattern pattern) {
    _periodService.addDischargePattern(cycle, pattern);
    notifyListeners();
  }

  double getAverageCycleLength() => _periodService.getAverageCycleLength();

  double getAveragePeriodDuration() => _periodService.getAveragePeriodDuration();

  CyclePrediction predictNextCycle({UserSettings? settings}) {
    return _fertilityService.predictNextCycle(settings: settings);
  }

  bool get isCurrentlyFertile => _fertilityService.isCurrentlyFertile();

  int getDaysUntilOvulation({UserSettings? settings}) {
    return _fertilityService.getDaysUntilOvulation(settings: settings);
  }

  double getFertilityLevelForDate(DateTime date, {UserSettings? settings}) {
    return _fertilityService.getFertilityLevelForDate(date, settings: settings);
  }

  List<Symptom> getAllSymptoms() => _periodService.getAllSymptoms();

  List<MoodEntry> getAllMoods() => _periodService.getAllMoods();
}
