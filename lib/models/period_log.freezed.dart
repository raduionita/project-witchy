// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PeriodLog _$PeriodLogFromJson(Map<String, dynamic> json) {
  return _PeriodLog.fromJson(json);
}

/// @nodoc
mixin _$PeriodLog {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  FlowIntensity? get intensity => throw _privateConstructorUsedError;
  List<String> get symptoms => throw _privateConstructorUsedError;
  String? get mood => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PeriodLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeriodLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeriodLogCopyWith<PeriodLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeriodLogCopyWith<$Res> {
  factory $PeriodLogCopyWith(PeriodLog value, $Res Function(PeriodLog) then) =
      _$PeriodLogCopyWithImpl<$Res, PeriodLog>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    FlowIntensity? intensity,
    List<String> symptoms,
    String? mood,
    String? notes,
  });
}

/// @nodoc
class _$PeriodLogCopyWithImpl<$Res, $Val extends PeriodLog>
    implements $PeriodLogCopyWith<$Res> {
  _$PeriodLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeriodLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? intensity = freezed,
    Object? symptoms = null,
    Object? mood = freezed,
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
            intensity:
                freezed == intensity
                    ? _value.intensity
                    : intensity // ignore: cast_nullable_to_non_nullable
                        as FlowIntensity?,
            symptoms:
                null == symptoms
                    ? _value.symptoms
                    : symptoms // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            mood:
                freezed == mood
                    ? _value.mood
                    : mood // ignore: cast_nullable_to_non_nullable
                        as String?,
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
abstract class _$$PeriodLogImplCopyWith<$Res>
    implements $PeriodLogCopyWith<$Res> {
  factory _$$PeriodLogImplCopyWith(
    _$PeriodLogImpl value,
    $Res Function(_$PeriodLogImpl) then,
  ) = __$$PeriodLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    FlowIntensity? intensity,
    List<String> symptoms,
    String? mood,
    String? notes,
  });
}

/// @nodoc
class __$$PeriodLogImplCopyWithImpl<$Res>
    extends _$PeriodLogCopyWithImpl<$Res, _$PeriodLogImpl>
    implements _$$PeriodLogImplCopyWith<$Res> {
  __$$PeriodLogImplCopyWithImpl(
    _$PeriodLogImpl _value,
    $Res Function(_$PeriodLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeriodLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? intensity = freezed,
    Object? symptoms = null,
    Object? mood = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$PeriodLogImpl(
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
        intensity:
            freezed == intensity
                ? _value.intensity
                : intensity // ignore: cast_nullable_to_non_nullable
                    as FlowIntensity?,
        symptoms:
            null == symptoms
                ? _value._symptoms
                : symptoms // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        mood:
            freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                    as String?,
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
class _$PeriodLogImpl implements _PeriodLog {
  const _$PeriodLogImpl({
    required this.id,
    required this.date,
    this.intensity,
    final List<String> symptoms = const <String>[],
    this.mood,
    this.notes,
  }) : _symptoms = symptoms;

  factory _$PeriodLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeriodLogImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final FlowIntensity? intensity;
  final List<String> _symptoms;
  @override
  @JsonKey()
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  @override
  final String? mood;
  @override
  final String? notes;

  @override
  String toString() {
    return 'PeriodLog(id: $id, date: $date, intensity: $intensity, symptoms: $symptoms, mood: $mood, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeriodLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    intensity,
    const DeepCollectionEquality().hash(_symptoms),
    mood,
    notes,
  );

  /// Create a copy of PeriodLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeriodLogImplCopyWith<_$PeriodLogImpl> get copyWith =>
      __$$PeriodLogImplCopyWithImpl<_$PeriodLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeriodLogImplToJson(this);
  }
}

abstract class _PeriodLog implements PeriodLog {
  const factory _PeriodLog({
    required final String id,
    required final DateTime date,
    final FlowIntensity? intensity,
    final List<String> symptoms,
    final String? mood,
    final String? notes,
  }) = _$PeriodLogImpl;

  factory _PeriodLog.fromJson(Map<String, dynamic> json) =
      _$PeriodLogImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  FlowIntensity? get intensity;
  @override
  List<String> get symptoms;
  @override
  String? get mood;
  @override
  String? get notes;

  /// Create a copy of PeriodLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeriodLogImplCopyWith<_$PeriodLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
