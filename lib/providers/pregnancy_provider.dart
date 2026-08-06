import 'package:flutter/foundation.dart';
import '../models/pregnancy_tracker.dart';
import '../services/storage_service.dart';
import '../services/cycle_service.dart';

class PregnancyProvider extends ChangeNotifier {
  final StorageService _storageService;
  final CycleService _cycleService;
  PregnancyTracker? _tracker;
  bool _isTracking = false;
  bool _isLoading = false;

  PregnancyProvider(this._storageService, this._cycleService) {
    _loadTracker();
  }

  PregnancyTracker? get tracker => _tracker;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;

  Future<void> _loadTracker() async {
    _isLoading = true;
    notifyListeners();

    _tracker = await _storageService.getPregnancyTracker();
    _isTracking = _tracker != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startPregnancyTracking(DateTime lastPeriodDate, {int cycleLength = 28}) async {
    final tracker = _cycleService.calculatePregnancyTracker(lastPeriodDate, cycleLength);
    _tracker = tracker;
    _isTracking = true;

    await _storageService.savePregnancyTracker(tracker);
    notifyListeners();
  }

  Future<void> stopPregnancyTracking() async {
    _tracker = null;
    _isTracking = false;
    await _storageService.savePregnancyTracker(PregnancyTracker(
      id: 'empty',
      lastPeriodDate: DateTime.now(),
    ));
    notifyListeners();
  }

  void refreshTracker() {
    if (_tracker != null) {
      final updated = _cycleService.calculatePregnancyTracker(
        _tracker!.lastPeriodDate,
        _tracker!.cycleLength,
      );
      _tracker = updated;
      notifyListeners();
    }
  }
}
