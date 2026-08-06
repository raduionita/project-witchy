import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier {
  String? name;
  String? email;
  int? lastPeriodDay;
  int cycleLength = 28;
  int periodDuration = 5;
  bool isAnonymous = true;

  UserProfile();

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void updateLastPeriodDay(int day) {
    lastPeriodDay = day;
    notifyListeners();
  }

  void updateCycleLength(int length) {
    cycleLength = length;
    notifyListeners();
  }

  void updatePeriodDuration(int duration) {
    periodDuration = duration;
    notifyListeners();
  }

  void setAnonymous(bool anonymous) {
    isAnonymous = anonymous;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'lastPeriodDay': lastPeriodDay,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'isAnonymous': isAnonymous,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = UserProfile();
    profile.name = json['name'] as String?;
    profile.email = json['email'] as String?;
    profile.lastPeriodDay = json['lastPeriodDay'] as int?;
    profile.cycleLength = json['cycleLength'] as int? ?? 28;
    profile.periodDuration = json['periodDuration'] as int? ?? 5;
    profile.isAnonymous = json['isAnonymous'] as bool? ?? true;
    return profile;
  }
}
