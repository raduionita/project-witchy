// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perimenopause_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PerimenopauseState _$PerimenopauseStateFromJson(Map<String, dynamic> json) {
  return _PerimenopauseState.fromJson(json);
}

/// @nodoc
mixin _$PerimenopauseState {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  bool get isTracking => throw _privateConstructorUsedError;

  /// Serializes this PerimenopauseState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PerimenopauseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PerimenopauseStateCopyWith<PerimenopauseState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PerimenopauseStateCopyWith<$Res> {
  factory $PerimenopauseStateCopyWith(
          PerimenopauseState value, $Res Function(PerimenopauseState) then) =
      _$PerimenopauseStateCopyWithImpl<$Res, PerimenopauseState>;
  @useResult
  $Res call({@HiveField(0) String id, @HiveField(1) bool isTracking});
}

/// @nodoc
class _$PerimenopauseStateCopyWithImpl<$Res, $Val extends PerimenopauseState>
    implements $PerimenopauseStateCopyWith<$Res> {
  _$PerimenopauseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PerimenopauseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isTracking = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isTracking: null == isTracking
          ? _value.isTracking
          : isTracking // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PerimenopauseStateImplCopyWith<$Res>
    implements $PerimenopauseStateCopyWith<$Res> {
  factory _$$PerimenopauseStateImplCopyWith(_$PerimenopauseStateImpl value,
          $Res Function(_$PerimenopauseStateImpl) then) =
      __$$PerimenopauseStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@HiveField(0) String id, @HiveField(1) bool isTracking});
}

/// @nodoc
class __$$PerimenopauseStateImplCopyWithImpl<$Res>
    extends _$PerimenopauseStateCopyWithImpl<$Res, _$PerimenopauseStateImpl>
    implements _$$PerimenopauseStateImplCopyWith<$Res> {
  __$$PerimenopauseStateImplCopyWithImpl(_$PerimenopauseStateImpl _value,
      $Res Function(_$PerimenopauseStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PerimenopauseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isTracking = null,
  }) {
    return _then(_$PerimenopauseStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isTracking: null == isTracking
          ? _value.isTracking
          : isTracking // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PerimenopauseStateImpl implements _PerimenopauseState {
  const _$PerimenopauseStateImpl(
      {@HiveField(0) required this.id, @HiveField(1) this.isTracking = false});

  factory _$PerimenopauseStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PerimenopauseStateImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @JsonKey()
  @HiveField(1)
  final bool isTracking;

  @override
  String toString() {
    return 'PerimenopauseState(id: $id, isTracking: $isTracking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PerimenopauseStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isTracking, isTracking) ||
                other.isTracking == isTracking));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, isTracking);

  /// Create a copy of PerimenopauseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PerimenopauseStateImplCopyWith<_$PerimenopauseStateImpl> get copyWith =>
      __$$PerimenopauseStateImplCopyWithImpl<_$PerimenopauseStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PerimenopauseStateImplToJson(
      this,
    );
  }
}

abstract class _PerimenopauseState implements PerimenopauseState {
  const factory _PerimenopauseState(
      {@HiveField(0) required final String id,
      @HiveField(1) final bool isTracking}) = _$PerimenopauseStateImpl;

  factory _PerimenopauseState.fromJson(Map<String, dynamic> json) =
      _$PerimenopauseStateImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  bool get isTracking;

  /// Create a copy of PerimenopauseState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PerimenopauseStateImplCopyWith<_$PerimenopauseStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
