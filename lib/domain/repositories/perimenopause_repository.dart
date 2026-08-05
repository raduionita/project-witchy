import 'package:witchy/domain/models/perimenopause_state.dart';

abstract class PerimenopauseRepository {
  Future<List<PerimenopauseState>> getAllStates();
  Future<void> saveState(PerimenopauseState state);
  Future<void> deleteState(String id);
}
