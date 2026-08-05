import 'package:witchy/domain/models/pregnancy_state.dart';
import 'package:witchy/domain/repositories/pregnancy_repository.dart';
import 'package:witchy/data/services/local_database_service.dart';
import 'package:witchy/core/constants/database_keys.dart';

class HivePregnancyRepository implements PregnancyRepository {
  final LocalDatabaseService _databaseService;

  HivePregnancyRepository(this._databaseService);

  @override
  Future<List<PregnancyState>> getAllStates() async {
    final box = _databaseService.getBox(DatabaseKeys.pregnancyStatesBox);
    return box.values.cast<PregnancyState>().toList();
  }

  @override
  Future<void> saveState(PregnancyState state) async {
    await _databaseService.getBox(DatabaseKeys.pregnancyStatesBox).put(state.id, state);
  }

  @override
  Future<void> deleteState(String id) async {
    await _databaseService.getBox(DatabaseKeys.pregnancyStatesBox).delete(id);
  }
}
