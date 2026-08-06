// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
  String get id => throw _privateConstructorUsedError;
  ReminderType get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  TimeOfDayModel get time => throw _privateConstructorUsedError;
  List<int> get weekday => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call({
    String id,
    ReminderType type,
    String title,
    TimeOfDayModel time,
    List<int> weekday,
    bool enabled,
    String? body,
  });

  $TimeOfDayModelCopyWith<$Res> get time;
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? time = null,
    Object? weekday = null,
    Object? enabled = null,
    Object? body = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as ReminderType,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            time:
                null == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as TimeOfDayModel,
            weekday:
                null == weekday
                    ? _value.weekday
                    : weekday // ignore: cast_nullable_to_non_nullable
                        as List<int>,
            enabled:
                null == enabled
                    ? _value.enabled
                    : enabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            body:
                freezed == body
                    ? _value.body
                    : body // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayModelCopyWith<$Res> get time {
    return $TimeOfDayModelCopyWith<$Res>(_value.time, (value) {
      return _then(_value.copyWith(time: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
    _$ReminderImpl value,
    $Res Function(_$ReminderImpl) then,
  ) = __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ReminderType type,
    String title,
    TimeOfDayModel time,
    List<int> weekday,
    bool enabled,
    String? body,
  });

  @override
  $TimeOfDayModelCopyWith<$Res> get time;
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
    _$ReminderImpl _value,
    $Res Function(_$ReminderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? time = null,
    Object? weekday = null,
    Object? enabled = null,
    Object? body = freezed,
  }) {
    return _then(
      _$ReminderImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as ReminderType,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        time:
            null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as TimeOfDayModel,
        weekday:
            null == weekday
                ? _value._weekday
                : weekday // ignore: cast_nullable_to_non_nullable
                    as List<int>,
        enabled:
            null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        body:
            freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    final List<int> weekday = const <int>[],
    this.enabled = true,
    this.body,
  }) : _weekday = weekday;

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

  @override
  final String id;
  @override
  final ReminderType type;
  @override
  final String title;
  @override
  final TimeOfDayModel time;
  final List<int> _weekday;
  @override
  @JsonKey()
  List<int> get weekday {
    if (_weekday is EqualUnmodifiableListView) return _weekday;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekday);
  }

  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? body;

  @override
  String toString() {
    return 'Reminder(id: $id, type: $type, title: $title, time: $time, weekday: $weekday, enabled: $enabled, body: $body)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality().equals(other._weekday, _weekday) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.body, body) || other.body == body));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    title,
    time,
    const DeepCollectionEquality().hash(_weekday),
    enabled,
    body,
  );

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(this);
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder({
    required final String id,
    required final ReminderType type,
    required final String title,
    required final TimeOfDayModel time,
    final List<int> weekday,
    final bool enabled,
    final String? body,
  }) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

  @override
  String get id;
  @override
  ReminderType get type;
  @override
  String get title;
  @override
  TimeOfDayModel get time;
  @override
  List<int> get weekday;
  @override
  bool get enabled;
  @override
  String? get body;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
