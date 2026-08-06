import 'package:flutter/foundation.dart';
import '../models/period_cycle.dart';
import '../models/symptom.dart';
import '../models/mood.dart';
import '../services/storage_service.dart';

class PeriodProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<PeriodCycle> _cycles = [];
  List<Symptom> _symptoms = [];
  List<MoodEntry> _moods = [];
  PeriodCycle? _currentCycle;
  bool _isLoading = false;

  PeriodProvider(this._storageService) {
    _loadData();
  }

  List<PeriodCycle> get cycles => _cycles;
  List<Symptom> get symptoms => _symptoms;
  List<MoodEntry> get moods => _moods;
  PeriodCycle? get currentCycle => _currentCycle;
  bool get isLoading => _isLoading;

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _cycles = await _storageService.getPeriodCycles();
    _symptoms = await _storageService.getSymptoms();
    _moods = await _storageService.getMoods();

    _updateCurrentCycle();
    _isLoading = false;
    notifyListeners();
  }

  void _updateCurrentCycle() {
    if (_cycles.isEmpty) {
      _currentCycle = null;
      return;
    }

    final sorted = List<PeriodCycle>.from(_cycles)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final latest = sorted.first;
    final now = DateTime.now();

    if (now.isAfter(latest.startDate) &&
        now.isBefore(latest.startDate.add(Duration(days: latest.cycleLength)))) {
      _currentCycle = latest;
    } else {
      _currentCycle = null;
    }
  }

  Future<void> addPeriodCycle(DateTime startDate, {DateTime? endDate}) async {
    final cycle = PeriodCycle(
      id: 'cycle_${startDate.millisecondsSinceEpoch}',
      startDate: startDate,
      endDate: endDate,
      cycleLength: _calculateAverageCycleLength(),
    );

    _cycles.add(cycle);
    await _storageService.savePeriodCycles(_cycles);
    _updateCurrentCycle();
    notifyListeners();
  }

  Future<void> updatePeriodCycle(PeriodCycle cycle) async {
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cycles[index] = cycle;
      await _storageService.savePeriodCycles(_cycles);
      _updateCurrentCycle();
      notifyListeners();
    }
  }

  Future<void> addSymptom(Symptom symptom) async {
    _symptoms.add(symptom);
    await _storageService.saveSymptoms(_symptoms);
    notifyListeners();
  }

  Future<void> updateSymptom(Symptom symptom) async {
    final index = _symptoms.indexWhere((s) => s.id == symptom.id);
    if (index != -1) {
      _symptoms[index] = symptom;
      await _storageService.saveSymptoms(_symptoms);
      notifyListeners();
    }
  }

  Future<void> addMood(MoodEntry mood) async {
    _moods.add(mood);
    await _storageService.saveMoods(_moods);
    notifyListeners();
  }

  int _calculateAverageCycleLength() {
    if (_cycles.length < 2) return 28;

    int totalLength = 0;
    int count = 0;
    for (int i = 1; i < _cycles.length; i++) {
      final cycle = _cycles[i];
      if (cycle.endDate != null) {
        totalLength += cycle.endDate!.difference(cycle.startDate).inDays;
        count++;
      }
    }

    return count > 0 ? (totalLength / count).round() : 28;
  }

  List<Symptom> getSymptomsForDateRange(DateTime start, DateTime end) {
    return _symptoms.where((s) {
      return s.date.isAfter(start.subtract(const Duration(days: 1))) &&
          s.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<MoodEntry> getMoodsForDateRange(DateTime start, DateTime end) {
    return _moods.where((m) {
      return m.date.isAfter(start.subtract(const Duration(days: 1))) &&
          m.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
