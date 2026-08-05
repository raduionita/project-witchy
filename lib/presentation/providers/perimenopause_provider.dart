import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/domain/models/perimenopause_state.dart';
import 'package:witchy/domain/repositories/perimenopause_repository.dart';
import 'package:uuid/uuid.dart';

class PerimenopauseProvider extends ChangeNotifier {
  final PerimenopauseRepository _repository;
  List<PerimenopauseState> _states = [];

  PerimenopauseProvider({required PerimenopauseRepository repository})
      : _repository = repository;

  List<PerimenopauseState> get states => List.unmodifiable(_states);

  Future<void> loadStates() async {
    _states = await _repository.getAllStates();
    notifyListeners();
  }

  Future<void> startTracking() async {
    final newState = PerimenopauseState(
      id: const Uuid().v4(),
      isTracking: true,
    );
    await _repository.saveState(newState);
    _states.add(newState);
    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (_states.isNotEmpty) {
      final currentState = _states.last;
      await _repository.saveState(currentState.copyWith(isTracking: false));
      _states.removeLast();
      notifyListeners();
    }
  }

  Future<void> deletePerimenopauseState(String id) async {
    await _repository.deleteState(id);
    _states.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
