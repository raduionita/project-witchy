import 'package:flutter/foundation.dart';
import '../models/cycle_model.dart';
import '../services/cycle_service.dart';

/// Manages the state of all recorded and predicted cycles.
class CycleProvider extends ChangeNotifier {
  final List<CycleModel> _cycles = [];
  List<CycleModel> get cycles => List.unmodifiable(_cycles);

  /// The current active cycle (most recent non-predicted).
  CycleModel? get activeCycle =>
      _cycles.where((c) => !c.isPredicted).isNotEmpty ? _cycles.last : null;

  /// All cycles including predictions.
  List<CycleModel> get allCycles =>
      [..._cycles, ...CycleService.predictCycles(_cycles, 3)];

  /// Adds a new cycle record.
  void addCycle(CycleModel cycle) {
    _cycles.add(cycle);
    notifyListeners();
  }

  /// Updates an existing cycle.
  void updateCycle(CycleModel cycle) {
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cycles[index] = cycle;
      notifyListeners();
    }
  }

  /// Removes a cycle.
  void removeCycle(int id) {
    _cycles.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Gets the average cycle length from recorded data.
  int get averageCycleLength {
    if (_cycles.isEmpty) return 28;
    final total = _cycles.fold<int>(0, (sum, c) => sum + c.cycleLength);
    return (total / _cycles.length).round();
  }

  /// Gets the average period duration.
  int get averagePeriodDuration {
    final recorded = _cycles.where((c) => c.endDate != null).toList();
    if (recorded.isEmpty) return 5;
    final total = recorded.fold<int>(
      0,
      (sum, c) => sum + c.endDate!.difference(c.startDate).inDays,
    );
    return (total / recorded.length).round();
  }

  /// Loads cycles from storage (placeholder for Hive integration).
  Future<void> loadCycles() async {
    // TODO: Load from Hive storage
    notifyListeners();
  }

  /// Saves cycles to storage (placeholder for Hive integration).
  Future<void> saveCycles() async {
    // TODO: Save to Hive storage
    notifyListeners();
  }
}