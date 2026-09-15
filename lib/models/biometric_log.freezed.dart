// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'biometric_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BiometricLog _$BiometricLogFromJson(Map<String, dynamic> json) {
  return _BiometricLog.fromJson(json);
}

/// @nodoc
mixin _$BiometricLog {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  BbtReading? get bbt => throw _privateConstructorUsedError;
  CervicalMucusType? get mucus => throw _privateConstructorUsedError;
  OvulationTestResult? get ovulationTest => throw _privateConstructorUsedError;
  PregnancyTestResult? get pregnancyTest => throw _privateConstructorUsedError;
  IntercourseLog? get intercourse => throw _privateConstructorUsedError;

  /// Serializes this BiometricLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BiometricLogCopyWith<BiometricLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BiometricLogCopyWith<$Res> {
  factory $BiometricLogCopyWith(
    BiometricLog value,
    $Res Function(BiometricLog) then,
  ) = _$BiometricLogCopyWithImpl<$Res, BiometricLog>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    BbtReading? bbt,
    CervicalMucusType? mucus,
    OvulationTestResult? ovulationTest,
    PregnancyTestResult? pregnancyTest,
    IntercourseLog? intercourse,
  });

  $BbtReadingCopyWith<$Res>? get bbt;
  $IntercourseLogCopyWith<$Res>? get intercourse;
}

/// @nodoc
class _$BiometricLogCopyWithImpl<$Res, $Val extends BiometricLog>
    implements $BiometricLogCopyWith<$Res> {
  _$BiometricLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bbt = freezed,
    Object? mucus = freezed,
    Object? ovulationTest = freezed,
    Object? pregnancyTest = freezed,
    Object? intercourse = freezed,
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
            bbt:
                freezed == bbt
                    ? _value.bbt
                    : bbt // ignore: cast_nullable_to_non_nullable
                        as BbtReading?,
            mucus:
                freezed == mucus
                    ? _value.mucus
                    : mucus // ignore: cast_nullable_to_non_nullable
                        as CervicalMucusType?,
            ovulationTest:
                freezed == ovulationTest
                    ? _value.ovulationTest
                    : ovulationTest // ignore: cast_nullable_to_non_nullable
                        as OvulationTestResult?,
            pregnancyTest:
                freezed == pregnancyTest
                    ? _value.pregnancyTest
                    : pregnancyTest // ignore: cast_nullable_to_non_nullable
                        as PregnancyTestResult?,
            intercourse:
                freezed == intercourse
                    ? _value.intercourse
                    : intercourse // ignore: cast_nullable_to_non_nullable
                        as IntercourseLog?,
          )
          as $Val,
    );
  }

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BbtReadingCopyWith<$Res>? get bbt {
    if (_value.bbt == null) {
      return null;
    }

    return $BbtReadingCopyWith<$Res>(_value.bbt!, (value) {
      return _then(_value.copyWith(bbt: value) as $Val);
    });
  }

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IntercourseLogCopyWith<$Res>? get intercourse {
    if (_value.intercourse == null) {
      return null;
    }

    return $IntercourseLogCopyWith<$Res>(_value.intercourse!, (value) {
      return _then(_value.copyWith(intercourse: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BiometricLogImplCopyWith<$Res>
    implements $BiometricLogCopyWith<$Res> {
  factory _$$BiometricLogImplCopyWith(
    _$BiometricLogImpl value,
    $Res Function(_$BiometricLogImpl) then,
  ) = __$$BiometricLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    BbtReading? bbt,
    CervicalMucusType? mucus,
    OvulationTestResult? ovulationTest,
    PregnancyTestResult? pregnancyTest,
    IntercourseLog? intercourse,
  });

  @override
  $BbtReadingCopyWith<$Res>? get bbt;
  @override
  $IntercourseLogCopyWith<$Res>? get intercourse;
}

/// @nodoc
class __$$BiometricLogImplCopyWithImpl<$Res>
    extends _$BiometricLogCopyWithImpl<$Res, _$BiometricLogImpl>
    implements _$$BiometricLogImplCopyWith<$Res> {
  __$$BiometricLogImplCopyWithImpl(
    _$BiometricLogImpl _value,
    $Res Function(_$BiometricLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bbt = freezed,
    Object? mucus = freezed,
    Object? ovulationTest = freezed,
    Object? pregnancyTest = freezed,
    Object? intercourse = freezed,
  }) {
    return _then(
      _$BiometricLogImpl(
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
        bbt:
            freezed == bbt
                ? _value.bbt
                : bbt // ignore: cast_nullable_to_non_nullable
                    as BbtReading?,
        mucus:
            freezed == mucus
                ? _value.mucus
                : mucus // ignore: cast_nullable_to_non_nullable
                    as CervicalMucusType?,
        ovulationTest:
            freezed == ovulationTest
                ? _value.ovulationTest
                : ovulationTest // ignore: cast_nullable_to_non_nullable
                    as OvulationTestResult?,
        pregnancyTest:
            freezed == pregnancyTest
                ? _value.pregnancyTest
                : pregnancyTest // ignore: cast_nullable_to_non_nullable
                    as PregnancyTestResult?,
        intercourse:
            freezed == intercourse
                ? _value.intercourse
                : intercourse // ignore: cast_nullable_to_non_nullable
                    as IntercourseLog?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BiometricLogImpl implements _BiometricLog {
  const _$BiometricLogImpl({
    required this.id,
    required this.date,
    this.bbt,
    this.mucus,
    this.ovulationTest,
    this.pregnancyTest,
    this.intercourse,
  });

  factory _$BiometricLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$BiometricLogImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final BbtReading? bbt;
  @override
  final CervicalMucusType? mucus;
  @override
  final OvulationTestResult? ovulationTest;
  @override
  final PregnancyTestResult? pregnancyTest;
  @override
  final IntercourseLog? intercourse;

  @override
  String toString() {
    return 'BiometricLog(id: $id, date: $date, bbt: $bbt, mucus: $mucus, ovulationTest: $ovulationTest, pregnancyTest: $pregnancyTest, intercourse: $intercourse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BiometricLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bbt, bbt) || other.bbt == bbt) &&
            (identical(other.mucus, mucus) || other.mucus == mucus) &&
            (identical(other.ovulationTest, ovulationTest) ||
                other.ovulationTest == ovulationTest) &&
            (identical(other.pregnancyTest, pregnancyTest) ||
                other.pregnancyTest == pregnancyTest) &&
            (identical(other.intercourse, intercourse) ||
                other.intercourse == intercourse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    bbt,
    mucus,
    ovulationTest,
    pregnancyTest,
    intercourse,
  );

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BiometricLogImplCopyWith<_$BiometricLogImpl> get copyWith =>
      __$$BiometricLogImplCopyWithImpl<_$BiometricLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BiometricLogImplToJson(this);
  }
}

abstract class _BiometricLog implements BiometricLog {
  const factory _BiometricLog({
    required final String id,
    required final DateTime date,
    final BbtReading? bbt,
    final CervicalMucusType? mucus,
    final OvulationTestResult? ovulationTest,
    final PregnancyTestResult? pregnancyTest,
    final IntercourseLog? intercourse,
  }) = _$BiometricLogImpl;

  factory _BiometricLog.fromJson(Map<String, dynamic> json) =
      _$BiometricLogImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  BbtReading? get bbt;
  @override
  CervicalMucusType? get mucus;
  @override
  OvulationTestResult? get ovulationTest;
  @override
  PregnancyTestResult? get pregnancyTest;
  @override
  IntercourseLog? get intercourse;

  /// Create a copy of BiometricLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BiometricLogImplCopyWith<_$BiometricLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
