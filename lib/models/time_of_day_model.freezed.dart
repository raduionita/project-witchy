// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_of_day_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimeOfDayModel _$TimeOfDayModelFromJson(Map<String, dynamic> json) {
  return _TimeOfDayModel.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDayModel {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  /// Serializes this TimeOfDayModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeOfDayModelCopyWith<TimeOfDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayModelCopyWith<$Res> {
  factory $TimeOfDayModelCopyWith(
    TimeOfDayModel value,
    $Res Function(TimeOfDayModel) then,
  ) = _$TimeOfDayModelCopyWithImpl<$Res, TimeOfDayModel>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayModelCopyWithImpl<$Res, $Val extends TimeOfDayModel>
    implements $TimeOfDayModelCopyWith<$Res> {
  _$TimeOfDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? minute = null}) {
    return _then(
      _value.copyWith(
            hour:
                null == hour
                    ? _value.hour
                    : hour // ignore: cast_nullable_to_non_nullable
                        as int,
            minute:
                null == minute
                    ? _value.minute
                    : minute // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeOfDayModelImplCopyWith<$Res>
    implements $TimeOfDayModelCopyWith<$Res> {
  factory _$$TimeOfDayModelImplCopyWith(
    _$TimeOfDayModelImpl value,
    $Res Function(_$TimeOfDayModelImpl) then,
  ) = __$$TimeOfDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayModelImplCopyWithImpl<$Res>
    extends _$TimeOfDayModelCopyWithImpl<$Res, _$TimeOfDayModelImpl>
    implements _$$TimeOfDayModelImplCopyWith<$Res> {
  __$$TimeOfDayModelImplCopyWithImpl(
    _$TimeOfDayModelImpl _value,
    $Res Function(_$TimeOfDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? minute = null}) {
    return _then(
      _$TimeOfDayModelImpl(
        hour:
            null == hour
                ? _value.hour
                : hour // ignore: cast_nullable_to_non_nullable
                    as int,
        minute:
            null == minute
                ? _value.minute
                : minute // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeOfDayModelImpl implements _TimeOfDayModel {
  const _$TimeOfDayModelImpl({required this.hour, required this.minute});

  factory _$TimeOfDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayModelImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDayModel(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayModelImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayModelImplCopyWith<_$TimeOfDayModelImpl> get copyWith =>
      __$$TimeOfDayModelImplCopyWithImpl<_$TimeOfDayModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayModelImplToJson(this);
  }
}

abstract class _TimeOfDayModel implements TimeOfDayModel {
  const factory _TimeOfDayModel({
    required final int hour,
    required final int minute,
  }) = _$TimeOfDayModelImpl;

  factory _TimeOfDayModel.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayModelImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;

  /// Create a copy of TimeOfDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeOfDayModelImplCopyWith<_$TimeOfDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
