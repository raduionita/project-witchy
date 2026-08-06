import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Baseline information about the user's menstrual profile.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    @Default(28) int averageCycleLength,
    @Default(5) int averagePeriodLength,
    @Default(14) int lutealPhaseLength,
    DateTime? firstPeriodDate,
    @Default(false) bool onboarded,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}