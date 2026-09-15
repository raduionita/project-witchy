// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bbt_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BbtReading _$BbtReadingFromJson(Map<String, dynamic> json) {
  return _BbtReading.fromJson(json);
}

/// @nodoc
mixin _$BbtReading {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get tempC => throw _privateConstructorUsedError;
  TimeOfDayModel? get takenAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this BbtReading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BbtReadingCopyWith<BbtReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BbtReadingCopyWith<$Res> {
  factory $BbtReadingCopyWith(
    BbtReading value,
    $Res Function(BbtReading) then,
  ) = _$BbtReadingCopyWithImpl<$Res, BbtReading>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    double tempC,
    TimeOfDayModel? takenAt,
    String? notes,
  });

  $TimeOfDayModelCopyWith<$Res>? get takenAt;
}

/// @nodoc
class _$BbtReadingCopyWithImpl<$Res, $Val extends BbtReading>
    implements $BbtReadingCopyWith<$Res> {
  _$BbtReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? tempC = null,
    Object? takenAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            tempC:
                null == tempC
                    ? _value.tempC
                    : tempC // ignore: cast_nullable_to_non_nullable
                        as double,
            takenAt:
                freezed == takenAt
                    ? _value.takenAt
                    : takenAt // ignore: cast_nullable_to_non_nullable
                        as TimeOfDayModel?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res>? get takenAt {
    if (_value.takenAt == null) {
      return null;
    }

    return $TimeOfDayModelCopyWith<$Res>(_value.takenAt!, (value) {
      return _then(_value.copyWith(takenAt: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BbtReadingImplCopyWith<$Res>
    implements $BbtReadingCopyWith<$Res> {
  factory _$$BbtReadingImplCopyWith(
    _$BbtReadingImpl value,
    $Res Function(_$BbtReadingImpl) then,
  ) = __$$BbtReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    double tempC,
    TimeOfDayModel? takenAt,
    String? notes,
  });

  @override
  $TimeOfDayModelCopyWith<$Res>? get takenAt;
}

/// @nodoc
class __$$BbtReadingImplCopyWithImpl<$Res>
    extends _$BbtReadingCopyWithImpl<$Res, _$BbtReadingImpl>
    implements _$$BbtReadingImplCopyWith<$Res> {
  __$$BbtReadingImplCopyWithImpl(
    _$BbtReadingImpl _value,
    $Res Function(_$BbtReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? tempC = null,
    Object? takenAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$BbtReadingImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        tempC:
            null == tempC
                ? _value.tempC
                : tempC // ignore: cast_nullable_to_non_nullable
                    as double,
        takenAt:
            freezed == takenAt
                ? _value.takenAt
                : takenAt // ignore: cast_nullable_to_non_nullable
                    as TimeOfDayModel?,
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
class _$BbtReadingImpl implements _BbtReading {
  const _$BbtReadingImpl({
    required this.id,
    required this.date,
    required this.tempC,
    this.takenAt,
    this.notes,
  });

  factory _$BbtReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BbtReadingImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final double tempC;
  @override
  final TimeOfDayModel? takenAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'BbtReading(id: $id, date: $date, tempC: $tempC, takenAt: $takenAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BbtReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.tempC, tempC) || other.tempC == tempC) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, tempC, takenAt, notes);

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BbtReadingImplCopyWith<_$BbtReadingImpl> get copyWith =>
      __$$BbtReadingImplCopyWithImpl<_$BbtReadingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BbtReadingImplToJson(this);
  }
}

abstract class _BbtReading implements BbtReading {
  const factory _BbtReading({
    required final String id,
    required final DateTime date,
    required final double tempC,
    final TimeOfDayModel? takenAt,
    final String? notes,
  }) = _$BbtReadingImpl;

  factory _BbtReading.fromJson(Map<String, dynamic> json) =
      _$BbtReadingImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  double get tempC;
  @override
  TimeOfDayModel? get takenAt;
  @override
  String? get notes;

  /// Create a copy of BbtReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BbtReadingImplCopyWith<_$BbtReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
