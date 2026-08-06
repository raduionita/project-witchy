import 'package:flutter/foundation.dart';
import '../models/period_cycle.dart';
import '../services/period_tracking_service.dart';

class CycleProvider extends ChangeNotifier {
  final PeriodTrackingService _service = PeriodTrackingService();
  List<PeriodCycle> _cycles = [];
  bool _isLoading = false;

  List<PeriodCycle> get cycles => _cycles;
  bool get isLoading => _isLoading;

  Future<void> loadCycles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cycles = await _service.loadCycles();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCycle(PeriodCycle cycle) async {
    await _service.saveCycle(cycle);
    _cycles.add(cycle);
    notifyListeners();
  }

  Future<void> updateCycle(PeriodCycle cycle) async {
    await _service.saveCycle(cycle);
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cycles[index] = cycle;
      notifyListeners();
    }
  }

  Future<void> deleteCycle(String cycleId) async {
    await _service.deleteCycle(cycleId);
    _cycles.removeWhere((c) => c.id == cycleId);
    notifyListeners();
  }
}
