// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleImpl _$$ArticleImplFromJson(Map<String, dynamic> json) =>
    _$ArticleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      body: json['body'] as String,
      publishedAt:
          json['publishedAt'] == null
              ? null
              : DateTime.parse(json['publishedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$ArticleImplToJson(_$ArticleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'body': instance.body,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
    };
