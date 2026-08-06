// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CoupleLink _$CoupleLinkFromJson(Map<String, dynamic> json) {
  return _CoupleLink.fromJson(json);
}

/// @nodoc
mixin _$CoupleLink {
  String get code => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get partnerDisplayName => throw _privateConstructorUsedError;
  bool get connected => throw _privateConstructorUsedError;

  /// Serializes this CoupleLink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoupleLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoupleLinkCopyWith<CoupleLink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoupleLinkCopyWith<$Res> {
  factory $CoupleLinkCopyWith(
    CoupleLink value,
    $Res Function(CoupleLink) then,
  ) = _$CoupleLinkCopyWithImpl<$Res, CoupleLink>;
  @useResult
  $Res call({
    String code,
    DateTime createdAt,
    String? partnerDisplayName,
    bool connected,
  });
}

/// @nodoc
class _$CoupleLinkCopyWithImpl<$Res, $Val extends CoupleLink>
    implements $CoupleLinkCopyWith<$Res> {
  _$CoupleLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoupleLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? createdAt = null,
    Object? partnerDisplayName = freezed,
    Object? connected = null,
  }) {
    return _then(
      _value.copyWith(
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            partnerDisplayName:
                freezed == partnerDisplayName
                    ? _value.partnerDisplayName
                    : partnerDisplayName // ignore: cast_nullable_to_non_nullable
                        as String?,
            connected:
                null == connected
                    ? _value.connected
                    : connected // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CoupleLinkImplCopyWith<$Res>
    implements $CoupleLinkCopyWith<$Res> {
  factory _$$CoupleLinkImplCopyWith(
    _$CoupleLinkImpl value,
    $Res Function(_$CoupleLinkImpl) then,
  ) = __$$CoupleLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    DateTime createdAt,
    String? partnerDisplayName,
    bool connected,
  });
}

/// @nodoc
class __$$CoupleLinkImplCopyWithImpl<$Res>
    extends _$CoupleLinkCopyWithImpl<$Res, _$CoupleLinkImpl>
    implements _$$CoupleLinkImplCopyWith<$Res> {
  __$$CoupleLinkImplCopyWithImpl(
    _$CoupleLinkImpl _value,
    $Res Function(_$CoupleLinkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CoupleLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? createdAt = null,
    Object? partnerDisplayName = freezed,
    Object? connected = null,
  }) {
    return _then(
      _$CoupleLinkImpl(
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        partnerDisplayName:
            freezed == partnerDisplayName
                ? _value.partnerDisplayName
                : partnerDisplayName // ignore: cast_nullable_to_non_nullable
                    as String?,
        connected:
            null == connected
                ? _value.connected
                : connected // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CoupleLinkImpl implements _CoupleLink {
  const _$CoupleLinkImpl({
    required this.code,
    required this.createdAt,
    this.partnerDisplayName,
    this.connected = false,
  });

  factory _$CoupleLinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoupleLinkImplFromJson(json);

  @override
  final String code;
  @override
  final DateTime createdAt;
  @override
  final String? partnerDisplayName;
  @override
  @JsonKey()
  final bool connected;

  @override
  String toString() {
    return 'CoupleLink(code: $code, createdAt: $createdAt, partnerDisplayName: $partnerDisplayName, connected: $connected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoupleLinkImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.partnerDisplayName, partnerDisplayName) ||
                other.partnerDisplayName == partnerDisplayName) &&
            (identical(other.connected, connected) ||
                other.connected == connected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, code, createdAt, partnerDisplayName, connected);

  /// Create a copy of CoupleLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoupleLinkImplCopyWith<_$CoupleLinkImpl> get copyWith =>
      __$$CoupleLinkImplCopyWithImpl<_$CoupleLinkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoupleLinkImplToJson(this);
  }
}

abstract class _CoupleLink implements CoupleLink {
  const factory _CoupleLink({
    required final String code,
    required final DateTime createdAt,
    final String? partnerDisplayName,
    final bool connected,
  }) = _$CoupleLinkImpl;

  factory _CoupleLink.fromJson(Map<String, dynamic> json) =
      _$CoupleLinkImpl.fromJson;

  @override
  String get code;
  @override
  DateTime get createdAt;
  @override
  String? get partnerDisplayName;
  @override
  bool get connected;

  /// Create a copy of CoupleLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoupleLinkImplCopyWith<_$CoupleLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
