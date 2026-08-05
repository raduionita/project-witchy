import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/domain/models/period_cycle.dart';
import 'package:witchy/domain/repositories/period_cycle_repository.dart';
import 'package:witchy/domain/services/cycle_predictor.dart';
import 'package:witchy/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class PeriodCycleProvider extends ChangeNotifier {
  final PeriodCycleRepository _repository;
  final CyclePredictor _predictor = CyclePredictor();
  final NotificationService _notificationService;
  List<PeriodCycle> _cycles = [];

  PeriodCycleProvider({
    required PeriodCycleRepository repository,
    required NotificationService notificationService,
  }) : _repository = repository, _notificationService = notificationService;

  List<PeriodCycle> get cycles => List.unmodifiable(_cycles);
  DateTime? get predictedNextStartDate => _predictor.predictNextCycleStart(
        completedCycles: _cycles.where((c) => c.isCompleted).toList(),
      );

  Future<void> loadCycles() async {
    _cycles = await _repository.getAllCycles();
    notifyListeners();
  }

  Future<void> startNewCycle(DateTime startDate) async {
    final newCycle = PeriodCycle(
      id: const Uuid().v4(),
      startDate: startDate,
      endDate: startDate, // Placeholder until finished
    );
    await _repository.saveCycle(newCycle);
    _cycles.add(newCycle);
    notifyListeners();

    // Schedule a reminder for the next predicted cycle if we have data
    final prediction = _predictor.predictNextCycleStart(
      completedCycles: _cycles.where((c) => c.isCompleted).toList(),
    );
    if (prediction != null && prediction.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: newCycle.id.hashCode,
        title: 'Cycle Update',
        body: 'Your next cycle is predicted to start soon!',
        scheduledTime: prediction,
      );
    }
  }

  Future<void> endCurrentCycle(String cycleId, DateTime endDate) async {
    final index = _cycles.indexWhere((c) => c.id == cycleId);
    if (index != -1) {
      final updatedCycle = _cycles[index].copyWith(
        endDate: endDate,
        isCompleted: true,
      );
      await _repository.saveCycle(updatedCycle);
      _cycles[index] = updatedCycle;
      notifyListeners();

      // Schedule next cycle reminder based on the newly completed cycle
      final prediction = _predictor.predictNextCycleStart(
        completedCycles: _cycles.where((c) => c.isCompleted).toList(),
      );
      if (prediction != null && prediction.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: cycleId.hashCode,
          title: 'Cycle Update',
          body: 'Your next cycle is predicted to start soon!',
          scheduledTime: prediction,
        );
      }
    }
  }

  Future<void> deleteCycle(String id) async {
    await _repository.deleteCycle(id);
    _cycles.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
