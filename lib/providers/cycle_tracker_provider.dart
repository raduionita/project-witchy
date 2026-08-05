// Cycle tracker provider - state management with persistence

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/cycle_models.dart';
import '../services/period_tracking_service.dart';
import '../services/persistence_service.dart';

/// Provider for managing cycle tracking state, predictions, and persistence
class CycleTrackerProvider extends ChangeNotifier {
  final PeriodTrackingService _service = PeriodTrackingService();
  final PersistenceService _persistence;

  CycleTrackerProvider(this._persistence);

  // Current cycle info
  int? _currentCycleDay;
  CyclePhase? _currentPhase;
  int? _daysUntilNextPeriod;
  int? _daysUntilOvulation;
  
  // Cycle predictions
  CyclePrediction? _predictions;

  // Monthly summary
  MonthlySummary? _monthlySummary;

  // Pregnancy state
  PregnancyInfo? _pregnancyInfo;

  // Perimenopause tracking
  PerimenopauseTracker? _perimenopauseTracker;

  // Symptom tracking
  final List<TrackedSymptom> _symptoms = [];

  // Cycle entries
  List<CycleEntry> get cycleEntries => _service.entries;

  // Symptom entries
  List<TrackedSymptom> get symptoms => _symptoms;

  // Current phase properties
  int? get currentCycleDay => _currentCycleDay;
  CyclePhase? get currentPhase => _currentPhase;
  
  int? get daysUntilNextPeriod => _daysUntilNextPeriod;
  int? get daysUntilOvulation => _daysUntilOvulation;
  
  CyclePrediction? get predictions => _predictions;
  MonthlySummary? get monthlySummary => _monthlySummary;

  bool get hasPregnancyInfo => _pregnancyInfo != null;
  PregnancyInfo? get pregnancyInfo => _pregnancyInfo;

  bool get hasPerimenopauseTracker => _perimenopauseTracker != null;
  PerimenopauseTracker? get perimenopauseTracker => _perimenopauseTracker;

  // Initialize from saved data
  void loadSavedData() async {
    final entries = _persistence.loadCycleEntries();
    
    // Add loaded entries to service
    for (final entry in entries) {
      _service.addEntry(entry);
    }

    final pregnancy = _persistence.loadPregnancyInfo();
    if (pregnancy != null) {
      _pregnancyInfo = pregnancy;
    }

    final perimenopause = _persistence.loadPerimenopauseTracker();
    if (perimenopause != null) {
      _perimenopauseTracker = perimenopause;
    }

    // Load symptoms from preferences
    final symptomJsons = _persistence.loadSymptoms();
    for (final json in symptomJsons) {
      _symptoms.add(TrackedSymptom.fromJson(json));
    }

    refreshState();
  }

  // Save all data to preferences
  Future<void> saveAllData() async {
    await _persistence.saveCycleEntries(_service.entries);
    
    if (_pregnancyInfo != null) {
      await _persistence.savePregnancyInfo(_pregnancyInfo!);
    }

    if (_perimenopauseTracker != null) {
      await _persistence.savePerimenopauseTracker(_perimenopauseTracker!);
    }

    await _persistence.saveSymptoms(_symptoms);
  }

  // Update all state from service
  void refreshState() {
    _currentCycleDay = _service.getCurrentCycleDay();
    _currentPhase = _service.getCurrentPhase();
    _daysUntilNextPeriod = _service.getDaysUntilNextPeriod();
    _daysUntilOvulation = _service.getDaysUntilNextOvulation();
    
    if (_cycleEntries.length >= 2) {
      _predictions = _service.calculatePredictions();
      _monthlySummary = _service.getMonthlySummary();
    }

    notifyListeners();
  }

  void addEntry(CycleEntry entry) {
    _service.addEntry(entry);
    refreshState();
    _saveToPersistence();
  }

  void removeEntry(String id) {
    _service.removeEntry(id);
    refreshState();
    _saveToPersistence();
  }

  void setPregnancyInfo(PregnancyInfo info) {
    _pregnancyInfo = info;
    notifyListeners();
    _saveToPersistence();
  }

  void setPerimenopauseTracker(PerimenopauseTracker tracker) {
    _perimenopauseTracker = tracker;
    notifyListeners();
    _saveToPersistence();
  }

  // Symptom tracking methods
  void addSymptom(TrackedSymptom symptom) {
    _symptoms.add(symptom);
    notifyListeners();
    _saveToPersistence();
  }

  void removeSymptom(String id) {
    _symptoms.removeWhere((s) => s.id == id);
    notifyListeners();
    _saveToPersistence();
  }

  List<TrackedSymptom> getSymptomsForDate(DateTime date) {
    return _symptoms.where((s) => s.date.toString().split(' ')[0] == date.toString().split(' ')[0]).toList();
  }

  double getAverageSymptomIntensity() {
    if (_symptoms.isEmpty) return 0;
    final total = _symptoms.fold(0, (sum, s) => sum + s.intensity);
    return total / _symptoms.length;
  }

  void clearAll() {
    _pregnancyInfo = null;
    _perimenopauseTracker = null;
    notifyListeners();
  }

  bool isFertileNow() => _predictions?.isFertileNow ?? false;

  Future<void> _saveToPersistence() async {
    await saveAllData();
  }

}
