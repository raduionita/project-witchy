import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/period_tracking_service.dart';

class ProfileProvider extends ChangeNotifier {
  final PeriodTrackingService _service = PeriodTrackingService();
  UserProfile _profile = UserProfile();
  bool _isLoading = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profileData = await _service.loadProfile();
      _profile = UserProfile.fromJson(profileData);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    await _service.saveProfile(_profile.toJson());
  }

  void updateName(String name) {
    _profile.updateName(name);
    notifyListeners();
  }

  void updateEmail(String email) {
    _profile.updateEmail(email);
    notifyListeners();
  }

  void updateLastPeriodDay(int day) {
    _profile.updateLastPeriodDay(day);
    notifyListeners();
  }

  void updateCycleLength(int length) {
    _profile.updateCycleLength(length);
    notifyListeners();
  }

  void updatePeriodDuration(int duration) {
    _profile.updatePeriodDuration(duration);
    notifyListeners();
  }

  void setAnonymous(bool anonymous) {
    _profile.setAnonymous(anonymous);
    notifyListeners();
  }
}
