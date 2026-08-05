/// Application provider for Witchy.
/// Manages user profile and app-wide state using Provider's ChangeNotifier pattern.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/period_entry.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// Application-level provider managing user profile and app state.
class AppProvider extends ChangeNotifier {
  AppProvider({required StorageService storageService})
      : _storage = storageService,
        _userProfile = const UserProfile();

  final StorageService _storage;

  /// The current user profile.
  UserProfile get userProfile => _userProfile;
  late final UserProfile _userProfile;

  /// Whether dark mode is enabled.
  bool get isDarkMode => _isDarkMode;
  late bool _isDarkMode = false;

  /// Whether onboarding has been completed.
  bool get isOnboardingComplete => _isOnboardingComplete;
  late bool _isOnboardingComplete = false;

  /// Whether the app is in anonymous mode (always true for MVP).
  bool get isAnonymousMode => true;

  /// Initializes the provider by loading settings from storage.
  Future<void> init() async {
    _isOnboardingComplete = await _storage.isOnboardingComplete();

    final cycleLength = await _storage.getCycleLength();
    final periodDuration = await _storage.getPeriodDuration();
    final lastPeriodDateStr = await _storage.getLastPeriodDate();

    DateTime? lastPeriodDate;
    if (lastPeriodDateStr != null) {
      try {
        lastPeriodDate = DateTime.parse(lastPeriodDateStr);
      } on FormatException {
        // Ignore malformed dates.
      }
    }

    _userProfile = UserProfile(
      cycleLengthDays: cycleLength ?? 28,
      periodDurationDays: periodDuration ?? 5,
      lastPeriodDate: lastPeriodDate,
    );

    notifyListeners();
  }

  /// Completes onboarding and saves to storage.
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await _storage.setOnboardingComplete();

    // Save cycle settings.
    await _storage.setCycleLength(_userProfile.cycleLengthDays);
    await _storage.setPeriodDuration(_userProfile.periodDurationDays);

    notifyListeners();
  }

  /// Updates the user profile with new cycle settings.
  Future<void> updateProfile({int? cycleLengthDays, int? periodDurationDays}) async {
    _userProfile = UserProfile(
      cycleLengthDays: cycleLengthDays ?? _userProfile.cycleLengthDays,
      periodDurationDays: periodDurationDays ?? _userProfile.periodDurationDays,
    );

    // Persist to storage.
    await _storage.setCycleLength(_userProfile.cycleLengthDays);
    await _storage.setPeriodDuration(_userProfile.periodDurationDays);

    notifyListeners();
  }

  /// Toggles dark mode.
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Returns the current theme (light or dark).
  Brightness get brightness => _isDarkMode ? Brightness.dark : Brightness.light;

  /// Returns the current theme data (light or dark).
  ThemeData get themeData => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  /// Returns the stored period entries as a list.
  Future<List<PeriodEntry>> getEntries() async {
    final jsonString = await _storage.getEntries();
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => PeriodEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on FormatException {
      return [];
    }
  }

  /// Saves a list of period entries to storage.
  Future<void> saveEntries(List<PeriodEntry> entries) async {
    final List<Map<String, dynamic>> jsonList =
        entries.map((e) => e.toJson()).toList();

    await _storage.setEntries(jsonEncode(jsonList));
  }
}
