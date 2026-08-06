// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  int get averageCycleLength => throw _privateConstructorUsedError;
  int get averagePeriodLength => throw _privateConstructorUsedError;
  int get lutealPhaseLength => throw _privateConstructorUsedError;
  DateTime? get firstPeriodDate => throw _privateConstructorUsedError;
  bool get onboarded => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String id,
    int averageCycleLength,
    int averagePeriodLength,
    int lutealPhaseLength,
    DateTime? firstPeriodDate,
    bool onboarded,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? averageCycleLength = null,
    Object? averagePeriodLength = null,
    Object? lutealPhaseLength = null,
    Object? firstPeriodDate = freezed,
    Object? onboarded = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            averageCycleLength:
                null == averageCycleLength
                    ? _value.averageCycleLength
                    : averageCycleLength // ignore: cast_nullable_to_non_nullable
                        as int,
            averagePeriodLength:
                null == averagePeriodLength
                    ? _value.averagePeriodLength
                    : averagePeriodLength // ignore: cast_nullable_to_non_nullable
                        as int,
            lutealPhaseLength:
                null == lutealPhaseLength
                    ? _value.lutealPhaseLength
                    : lutealPhaseLength // ignore: cast_nullable_to_non_nullable
                        as int,
            firstPeriodDate:
                freezed == firstPeriodDate
                    ? _value.firstPeriodDate
                    : firstPeriodDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            onboarded:
                null == onboarded
                    ? _value.onboarded
                    : onboarded // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int averageCycleLength,
    int averagePeriodLength,
    int lutealPhaseLength,
    DateTime? firstPeriodDate,
    bool onboarded,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? averageCycleLength = null,
    Object? averagePeriodLength = null,
    Object? lutealPhaseLength = null,
    Object? firstPeriodDate = freezed,
    Object? onboarded = null,
  }) {
    return _then(
      _$UserProfileImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        averageCycleLength:
            null == averageCycleLength
                ? _value.averageCycleLength
                : averageCycleLength // ignore: cast_nullable_to_non_nullable
                    as int,
        averagePeriodLength:
            null == averagePeriodLength
                ? _value.averagePeriodLength
                : averagePeriodLength // ignore: cast_nullable_to_non_nullable
                    as int,
        lutealPhaseLength:
            null == lutealPhaseLength
                ? _value.lutealPhaseLength
                : lutealPhaseLength // ignore: cast_nullable_to_non_nullable
                    as int,
        firstPeriodDate:
            freezed == firstPeriodDate
                ? _value.firstPeriodDate
                : firstPeriodDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        onboarded:
            null == onboarded
                ? _value.onboarded
                : onboarded // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.lutealPhaseLength = 14,
    this.firstPeriodDate,
    this.onboarded = false,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final int averageCycleLength;
  @override
  @JsonKey()
  final int averagePeriodLength;
  @override
  @JsonKey()
  final int lutealPhaseLength;
  @override
  final DateTime? firstPeriodDate;
  @override
  @JsonKey()
  final bool onboarded;

  @override
  String toString() {
    return 'UserProfile(id: $id, averageCycleLength: $averageCycleLength, averagePeriodLength: $averagePeriodLength, lutealPhaseLength: $lutealPhaseLength, firstPeriodDate: $firstPeriodDate, onboarded: $onboarded)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.averageCycleLength, averageCycleLength) ||
                other.averageCycleLength == averageCycleLength) &&
            (identical(other.averagePeriodLength, averagePeriodLength) ||
                other.averagePeriodLength == averagePeriodLength) &&
            (identical(other.lutealPhaseLength, lutealPhaseLength) ||
                other.lutealPhaseLength == lutealPhaseLength) &&
            (identical(other.firstPeriodDate, firstPeriodDate) ||
                other.firstPeriodDate == firstPeriodDate) &&
            (identical(other.onboarded, onboarded) ||
                other.onboarded == onboarded));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    averageCycleLength,
    averagePeriodLength,
    lutealPhaseLength,
    firstPeriodDate,
    onboarded,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String id,
    final int averageCycleLength,
    final int averagePeriodLength,
    final int lutealPhaseLength,
    final DateTime? firstPeriodDate,
    final bool onboarded,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  int get averageCycleLength;
  @override
  int get averagePeriodLength;
  @override
  int get lutealPhaseLength;
  @override
  DateTime? get firstPeriodDate;
  @override
  bool get onboarded;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
