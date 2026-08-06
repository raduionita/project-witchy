// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSessionImpl _$$AuthSessionImplFromJson(Map<String, dynamic> json) =>
    _$AuthSessionImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      provider: $enumDecode(_$AuthProviderTypeEnumMap, json['provider']),
      signedInAt: DateTime.parse(json['signedInAt'] as String),
    );

Map<String, dynamic> _$$AuthSessionImplToJson(_$AuthSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'provider': _$AuthProviderTypeEnumMap[instance.provider]!,
      'signedInAt': instance.signedInAt.toIso8601String(),
    };

const _$AuthProviderTypeEnumMap = {
  AuthProviderType.google: 'google',
  AuthProviderType.apple: 'apple',
  AuthProviderType.anonymous: 'anonymous',
};
