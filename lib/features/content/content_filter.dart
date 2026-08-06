import 'package:flutter/foundation.dart';

import '../../models/article.dart';
import '../../models/video.dart';

/// The kind of content surfaced in the library.
enum ContentType { article, video }

/// A lightweight, normalized view of a library item used for browsing.
///
/// Keeps the list UI free from model-specific fields; the full [Article] or
/// [Video] stays available on the provider for reading/viewing.
@immutable
class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    this.publishedAt,
    this.summary,
  });

  final String id;
  final String title;
  final String category;
  final ContentType type;
  final DateTime? publishedAt;
  final String? summary;

  factory ContentItem.fromArticle(Article article) => ContentItem(
        id: article.id,
        title: article.title,
        category: article.category,
        type: ContentType.article,
        publishedAt: article.publishedAt,
      );

  factory ContentItem.fromVideo(Video video) => ContentItem(
        id: video.id,
        title: video.title,
        category: video.category,
        type: ContentType.video,
        publishedAt: video.publishedAt,
        summary: video.description,
      );
}

/// Filters [items] by optional [type], [category], and case-insensitive
/// [query] matching against the title. Pure so it is easy to unit test.
List<ContentItem> filterContent({
  required List<ContentItem> items,
  ContentType? type,
  String? category,
  String query = '',
}) {
  final String needle = query.trim().toLowerCase();
  return items.where((ContentItem item) {
    if (type != null && item.type != type) return false;
    if (category != null && item.category != category) return false;
    if (needle.isNotEmpty && !item.title.toLowerCase().contains(needle)) {
      return false;
    }
    return true;
  }).toList();
}

/// The distinct categories among [items], sorted alphabetically.
List<String> contentCategories(List<ContentItem> items) {
  final Set<String> seen = <String>{};
  for (final ContentItem item in items) {
    seen.add(item.category);
  }
  final List<String> categories = seen.toList()..sort();
  return categories;
}
