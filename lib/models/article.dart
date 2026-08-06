import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

/// A piece of health education content shown in the Content Library.
@freezed
abstract class Article with _$Article {
  const factory Article({
    required String id,
    required String title,
    required String category,
    required String body,
    DateTime? publishedAt,
    @Default(false) bool isFavorite,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}