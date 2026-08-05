import 'package:witchy/domain/models/pregnancy_state.dart';

abstract class PregnancyRepository {
  Future<List<PregnancyState>> getAllStates();
  Future<void> saveState(PregnancyState state);
  Future<void> deleteState(String id);
}
