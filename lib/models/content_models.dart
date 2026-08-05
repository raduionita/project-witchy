// Content library model for health articles

import 'package:freezed_annotation/freezed_annotation.dart';
part 'content_models.freezed.dart';
part 'content_models.g.dart';

/// Category of health content
enum ContentCategory {
  menstruation,
  fertility,
  pregnancy,
  perimenopause,
  pms,
  generalHealth,
}

/// An article or resource in the health content library
@freezed
class HealthArticle with _$HealthArticle {
  const factory HealthArticle({
    required String id,
    required String title,
    required String description,
    required ContentCategory category,
    required Duration readTimeMinutes,
    DateTime? publishedDate,
  }) = _HealthArticle;

  factory HealthArticle.fromJson(Map<String, dynamic> json) =>
      $HealthArticleFromJson(json);

  Map<String, dynamic> toJson() => _$HealthArticleToJson(this);
}

/// A curated set of articles for a specific topic
@freezed
class ArticleCollection with _$ArticleCollection {
  const factory ArticleCollection({
    required String id,
    required String title,
    required String description,
    required List<HealthArticle> articles,
  }) = _ArticleCollection;

  factory ArticleCollection.fromJson(Map<String, dynamic> json) =>
      $ArticleCollectionFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleCollectionToJson(this);
}
