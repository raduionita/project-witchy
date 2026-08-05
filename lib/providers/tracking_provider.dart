/// Tracking provider for Witchy.
/// Manages period entries CRUD and cycle calculations using Provider's ChangeNotifier pattern.
library;

import 'package:flutter/foundation.dart';

import '../models/period_entry.dart';
import '../models/user_profile.dart';
import 'app_provider.dart';

/// Provider for tracking period entries and cycle calculations.
class TrackingProvider extends ChangeNotifier {
  TrackingProvider({required AppProvider appProvider}) : _appProvider = appProvider;

  final AppProvider _appProvider;

  /// Returns the current user profile from app provider.
  UserProfile get userProfile => _appProvider.userProfile;

  /// The current list of period entries, sorted by start date (newest first).
  List<PeriodEntry> get entries => _entries;
  late List<PeriodEntry> _entries = [];

  /// Whether data is being loaded from storage.
  bool get isLoading => _isLoading;
  late bool _isLoading = false;

  /// Initializes the provider by loading entries from app provider.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _entries = await _appProvider.getEntries();
    if (_entries.isEmpty) {
      // Sort by start date descending.
      _entries.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Returns the current cycle day based on the most recent period entry.
  int? getCurrentCycleDay() {
    if (_entries.isEmpty) return null;

    final referenceDate = _appProvider.userProfile.lastPeriodDate ?? _entries.first.startDate;
    return (DateTime.now().difference(referenceDate).inDays + 1);
  }

  /// Returns the number of days until the next expected period, or null if already started.
  int? getDaysUntilNextPeriod() {
    if (_entries.isEmpty) return null;

    final latestEntry = _entries.first;
    final cycleLength = _appProvider.userProfile.cycleLengthDays;

    final nextPeriodDate = latestEntry.startDate.add(Duration(days: cycleLength));
    final now = DateTime.now();

    if (nextPeriodDate.isBefore(now)) {
      return null; // Period has started or is overdue.
    }

    return nextPeriodDate.difference(now).inDays;
  }

  /// Returns the estimated ovulation date based on the latest entry.
  DateTime? getOvulationDate() {
    if (_entries.isEmpty) return null;

    final latestEntry = _entries.first;
    final cycleLength = _appProvider.userProfile.cycleLengthDays;

    // Ovulation typically occurs 14 days before the next period.
    final nextPeriod = latestEntry.startDate.add(Duration(days: cycleLength));
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Returns the fertile window (start and end dates).
  (DateTime, DateTime)? getFertileWindow() {
    final ovulation = getOvulationDate();
    if (ovulation == null) return null;

    final start = ovulation.subtract(const Duration(days: 5));
    final end = ovulation.add(const Duration(days: 1));
    return (start, end);
  }

  /// Adds a new period entry and persists it.
  Future<void> addEntry(PeriodEntry entry) async {
    _entries.add(entry);

    // Sort by start date descending.
    _entries.sort((a, b) => b.startDate.compareTo(a.startDate));

    await _appProvider.saveEntries(_entries);
    notifyListeners();
  }

  /// Deletes a period entry by ID and persists.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);

    await _appProvider.saveEntries(_entries);
    notifyListeners();
  }

  /// Returns whether a given date is within any logged period.
  bool isDateInPeriod(DateTime date) {
    for (final entry in _entries) {
      final end = entry.endDate ?? DateTime.now();
      if (date.isAfter(entry.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  /// Returns whether a given date is within the fertile window.
  bool isDateFertile(DateTime date) {
    final window = getFertileWindow();
    if (window == null) return false;

    final (start, end) = window;
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  /// Returns whether a given date is an ovulation day.
  bool isDateOvulation(DateTime date) {
    final ovulation = getOvulationDate();
    if (ovulation == null) return false;

    return date.day == ovulation.day &&
        date.month == ovulation.month &&
        date.year == ovulation.year;
  }
}
