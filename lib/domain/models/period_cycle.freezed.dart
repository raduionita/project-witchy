// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PeriodCycle _$PeriodCycleFromJson(Map<String, dynamic> json) {
  return _PeriodCycle.fromJson(json);
}

/// @nodoc
mixin _$PeriodCycle {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get startDate => throw _privateConstructorUsedError;
  @HiveField(2)
  DateTime get endDate => throw _privateConstructorUsedError;
  @HiveField(3)
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this PeriodCycle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeriodCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeriodCycleCopyWith<PeriodCycle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodCycleCopyWith<$Res> {
  factory $PeriodCycleCopyWith(
          PeriodCycle value, $Res Function(PeriodCycle) then) =
      _$PeriodCycleCopyWithImpl<$Res, PeriodCycle>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime startDate,
      @HiveField(2) DateTime endDate,
      @HiveField(3) bool isCompleted});
}

/// @nodoc
class _$PeriodCycleCopyWithImpl<$Res, $Val extends PeriodCycle>
    implements $PeriodCycleCopyWith<$Res> {
  _$PeriodCycleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeriodCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PeriodCycleImplCopyWith<$Res>
    implements $PeriodCycleCopyWith<$Res> {
  factory _$$PeriodCycleImplCopyWith(
          _$PeriodCycleImpl value, $Res Function(_$PeriodCycleImpl) then) =
      __$$PeriodCycleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime startDate,
      @HiveField(2) DateTime endDate,
      @HiveField(3) bool isCompleted});
}

/// @nodoc
class __$$PeriodCycleImplCopyWithImpl<$Res>
    extends _$PeriodCycleCopyWithImpl<$Res, _$PeriodCycleImpl>
    implements _$$PeriodCycleImplCopyWith<$Res> {
  __$$PeriodCycleImplCopyWithImpl(
      _$PeriodCycleImpl _value, $Res Function(_$PeriodCycleImpl) _then)
      : super(_value, _then);

  /// Create a copy of PeriodCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isCompleted = null,
  }) {
    return _then(_$PeriodCycleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PeriodCycleImpl implements _PeriodCycle {
  const _$PeriodCycleImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.startDate,
      @HiveField(2) required this.endDate,
      @HiveField(3) this.isCompleted = false});

  factory _$PeriodCycleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodCycleImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime startDate;
  @override
  @HiveField(2)
  final DateTime endDate;
  @override
  @JsonKey()
  @HiveField(3)
  final bool isCompleted;

  @override
  String toString() {
    return 'PeriodCycle(id: $id, startDate: $startDate, endDate: $endDate, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodCycleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startDate, endDate, isCompleted);

  /// Create a copy of PeriodCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodCycleImplCopyWith<_$PeriodCycleImpl> get copyWith =>
      __$$PeriodCycleImplCopyWithImpl<_$PeriodCycleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodCycleImplToJson(
      this,
    );
  }
}

abstract class _PeriodCycle implements PeriodCycle {
  const factory _PeriodCycle(
      {@HiveField(0) required final String id,
      @HiveField(1) required final DateTime startDate,
      @HiveField(2) required final DateTime endDate,
      @HiveField(3) final bool isCompleted}) = _$PeriodCycleImpl;

  factory _PeriodCycle.fromJson(Map<String, dynamic> json) =
      _$PeriodCycleImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  DateTime get startDate;
  @override
  @HiveField(2)
  DateTime get endDate;
  @override
  @HiveField(3)
  bool get isCompleted;

  /// Create a copy of PeriodCycle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeriodCycleImplCopyWith<_$PeriodCycleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
