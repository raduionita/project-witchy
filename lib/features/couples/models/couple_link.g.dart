// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoupleLinkImpl _$$CoupleLinkImplFromJson(Map<String, dynamic> json) =>
    _$CoupleLinkImpl(
      code: json['code'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      partnerDisplayName: json['partnerDisplayName'] as String?,
      connected: json['connected'] as bool? ?? false,
    );

Map<String, dynamic> _$$CoupleLinkImplToJson(_$CoupleLinkImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'createdAt': instance.createdAt.toIso8601String(),
      'partnerDisplayName': instance.partnerDisplayName,
      'connected': instance.connected,
    };
