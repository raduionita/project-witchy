// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cycle _$CycleFromJson(Map<String, dynamic> json) {
  return _Cycle.fromJson(json);
}

/// @nodoc
mixin _$Cycle {
  String get id => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int? get length => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Cycle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CycleCopyWith<Cycle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CycleCopyWith<$Res> {
  factory $CycleCopyWith(Cycle value, $Res Function(Cycle) then) =
      _$CycleCopyWithImpl<$Res, Cycle>;
  @useResult
  $Res call({
    String id,
    DateTime startDate,
    DateTime? endDate,
    int? length,
    String? notes,
  });
}

/// @nodoc
class _$CycleCopyWithImpl<$Res, $Val extends Cycle>
    implements $CycleCopyWith<$Res> {
  _$CycleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? length = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            length:
                freezed == length
                    ? _value.length
                    : length // ignore: cast_nullable_to_non_nullable
                        as int?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CycleImplCopyWith<$Res> implements $CycleCopyWith<$Res> {
  factory _$$CycleImplCopyWith(
    _$CycleImpl value,
    $Res Function(_$CycleImpl) then,
  ) = __$$CycleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime startDate,
    DateTime? endDate,
    int? length,
    String? notes,
  });
}

/// @nodoc
class __$$CycleImplCopyWithImpl<$Res>
    extends _$CycleCopyWithImpl<$Res, _$CycleImpl>
    implements _$$CycleImplCopyWith<$Res> {
  __$$CycleImplCopyWithImpl(
    _$CycleImpl _value,
    $Res Function(_$CycleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Cycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? length = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$CycleImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        length:
            freezed == length
                ? _value.length
                : length // ignore: cast_nullable_to_non_nullable
                    as int?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CycleImpl implements _Cycle {
  const _$CycleImpl({
    required this.id,
    required this.startDate,
    this.endDate,
    this.length,
    this.notes,
  });

  factory _$CycleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CycleImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final int? length;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Cycle(id: $id, startDate: $startDate, endDate: $endDate, length: $length, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CycleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.length, length) || other.length == length) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startDate, endDate, length, notes);

  /// Create a copy of Cycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CycleImplCopyWith<_$CycleImpl> get copyWith =>
      __$$CycleImplCopyWithImpl<_$CycleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CycleImplToJson(this);
  }
}

abstract class _Cycle implements Cycle {
  const factory _Cycle({
    required final String id,
    required final DateTime startDate,
    final DateTime? endDate,
    final int? length,
    final String? notes,
  }) = _$CycleImpl;

  factory _Cycle.fromJson(Map<String, dynamic> json) = _$CycleImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  int? get length;
  @override
  String? get notes;

  /// Create a copy of Cycle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CycleImplCopyWith<_$CycleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
