import 'package:flutter/foundation.dart';
import '../models/fertility_prediction.dart';
import '../services/storage_service.dart';
import '../services/cycle_service.dart';

class FertilityProvider extends ChangeNotifier {
  final StorageService _storageService;
  final CycleService _cycleService;
  List<FertilityPrediction> _predictions = [];
  FertilityPrediction? _currentPrediction;
  bool _isLoading = false;

  FertilityProvider(this._storageService, this._cycleService) {
    _loadData();
  }

  List<FertilityPrediction> get predictions => _predictions;
  FertilityPrediction? get currentPrediction => _currentPrediction;
  bool get isLoading => _isLoading;

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _predictions = await _storageService.getFertilityPredictions();
    _updateCurrentPrediction();
    _isLoading = false;
    notifyListeners();
  }

  void _updateCurrentPrediction() {
    if (_predictions.isEmpty) {
      _currentPrediction = null;
      return;
    }

    final sorted = List<FertilityPrediction>.from(_predictions)
      ..sort((a, b) => b.cycleStartDate.compareTo(a.cycleStartDate));

    _currentPrediction = sorted.first;
  }

  Future<void> predictFertility({
    required DateTime lastPeriodStart,
    int cycleLength = 28,
  }) async {
    final prediction = _cycleService.predictFertility(lastPeriodStart, cycleLength);

    _predictions.insert(0, prediction);
    _currentPrediction = prediction;

    await _storageService.saveFertilityPredictions(_predictions);
    notifyListeners();
  }

  bool isCurrentlyFertile() {
    if (_currentPrediction == null) return false;

    final now = DateTime.now();
    final prediction = _currentPrediction!;

    return now.isAfter(prediction.fertileWindowStart!) &&
        now.isBefore(prediction.fertileWindowEnd!);
  }

  bool isCurrentlyOvulating() {
    if (_currentPrediction?.ovulationDate == null) return false;

    final now = DateTime.now();
    final ovulationDate = _currentPrediction!.ovulationDate!;

    return now.isAfter(ovulationDate.subtract(const Duration(days: 2))) &&
        now.isBefore(ovulationDate.add(const Duration(days: 2)));
  }

  int getDaysToOvulation() {
    if (_currentPrediction?.ovulationDate == null) return -1;

    final now = DateTime.now();
    final ovulationDate = _currentPrediction!.ovulationDate!;

    return ovulationDate.difference(now).inDays;
  }
}
