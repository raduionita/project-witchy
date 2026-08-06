import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService;
  UserProfile? _profile;
  bool _isLoading = false;

  UserProvider(this._storageService) {
    _loadProfile();
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isOnboardingCompleted => _profile != null;

  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _storageService.getUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await _storageService.saveUserProfile(profile);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    notifyListeners();
  }
}
