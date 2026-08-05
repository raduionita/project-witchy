// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pregnancy_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PregnancyState _$PregnancyStateFromJson(Map<String, dynamic> json) {
  return _PregnancyState.fromJson(json);
}

/// @nodoc
mixin _$PregnancyState {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get conceptionDate => throw _privateConstructorUsedError;
  @HiveField(2)
  bool get isCurrent => throw _privateConstructorUsedError;

  /// Serializes this PregnancyState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PregnancyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PregnancyStateCopyWith<PregnancyState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PregnancyStateCopyWith<$Res> {
  factory $PregnancyStateCopyWith(
          PregnancyState value, $Res Function(PregnancyState) then) =
      _$PregnancyStateCopyWithImpl<$Res, PregnancyState>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime conceptionDate,
      @HiveField(2) bool isCurrent});
}

/// @nodoc
class _$PregnancyStateCopyWithImpl<$Res, $Val extends PregnancyState>
    implements $PregnancyStateCopyWith<$Res> {
  _$PregnancyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PregnancyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conceptionDate = null,
    Object? isCurrent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conceptionDate: null == conceptionDate
          ? _value.conceptionDate
          : conceptionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PregnancyStateImplCopyWith<$Res>
    implements $PregnancyStateCopyWith<$Res> {
  factory _$$PregnancyStateImplCopyWith(_$PregnancyStateImpl value,
          $Res Function(_$PregnancyStateImpl) then) =
      __$$PregnancyStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime conceptionDate,
      @HiveField(2) bool isCurrent});
}

/// @nodoc
class __$$PregnancyStateImplCopyWithImpl<$Res>
    extends _$PregnancyStateCopyWithImpl<$Res, _$PregnancyStateImpl>
    implements _$$PregnancyStateImplCopyWith<$Res> {
  __$$PregnancyStateImplCopyWithImpl(
      _$PregnancyStateImpl _value, $Res Function(_$PregnancyStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PregnancyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conceptionDate = null,
    Object? isCurrent = null,
  }) {
    return _then(_$PregnancyStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conceptionDate: null == conceptionDate
          ? _value.conceptionDate
          : conceptionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _value.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PregnancyStateImpl implements _PregnancyState {
  const _$PregnancyStateImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.conceptionDate,
      @HiveField(2) this.isCurrent = false});

  factory _$PregnancyStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PregnancyStateImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime conceptionDate;
  @override
  @JsonKey()
  @HiveField(2)
  final bool isCurrent;

  @override
  String toString() {
    return 'PregnancyState(id: $id, conceptionDate: $conceptionDate, isCurrent: $isCurrent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PregnancyStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conceptionDate, conceptionDate) ||
                other.conceptionDate == conceptionDate) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, conceptionDate, isCurrent);

  /// Create a copy of PregnancyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PregnancyStateImplCopyWith<_$PregnancyStateImpl> get copyWith =>
      __$$PregnancyStateImplCopyWithImpl<_$PregnancyStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PregnancyStateImplToJson(
      this,
    );
  }
}

abstract class _PregnancyState implements PregnancyState {
  const factory _PregnancyState(
      {@HiveField(0) required final String id,
      @HiveField(1) required final DateTime conceptionDate,
      @HiveField(2) final bool isCurrent}) = _$PregnancyStateImpl;

  factory _PregnancyState.fromJson(Map<String, dynamic> json) =
      _$PregnancyStateImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  DateTime get conceptionDate;
  @override
  @HiveField(2)
  bool get isCurrent;

  /// Create a copy of PregnancyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PregnancyStateImplCopyWith<_$PregnancyStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
