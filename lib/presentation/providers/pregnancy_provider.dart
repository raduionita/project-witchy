import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/domain/models/pregnancy_state.dart';
import 'package:witchy/domain/repositories/pregnancy_repository.dart';
import 'package:uuid/uuid.dart';

class PregnancyProvider extends ChangeNotifier {
  final PregnancyRepository _repository;
  List<PregnancyState> _states = [];

  PregnancyProvider({required PregnancyRepository repository})
      : _repository = repository;

  List<PregnancyState> get states => List.unmodifiable(_states);

  Future<void> loadStates() async {
    _states = await _repository.getAllStates();
    notifyListeners();
  }

  Future<void> startPregnancy(DateTime conceptionDate) async {
    final newState = PregnancyState(
      id: const Uuid().v4(),
      conceptionDate: conceptionDate,
      isCurrent: true,
    );
    await _repository.saveState(newState);
    _states.add(newState);
    notifyListeners();
  }

  Future<void> endPregnancy(String id) async {
    final index = _states.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updatedState = _states[index].copyWith(isCurrent: false);
      await _repository.saveState(updatedState);
      _states[index] = updatedState;
      notifyListeners();
    }
  }

  Future<void> deletePregnancy(String id) async {
    await _repository.deleteState(id);
    _states.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
