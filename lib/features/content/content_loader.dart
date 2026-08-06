import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/article.dart';
import '../../models/video.dart';

/// Source of the privacy-first, locally seeded content catalog.
///
/// The production implementation reads from the assets bundle, but tests can
/// supply a fake to exercise provider logic without I/O.
abstract class ContentSource {
  const ContentSource();

  /// Loads the seeded articles.
  Future<List<Article>> loadArticles();

  /// Loads the seeded videos.
  Future<List<Video>> loadVideos();
}

/// Loads the curated catalog bundled with the app. No network, no personal
/// data — just local education shipped alongside the app.
class AssetContentSource extends ContentSource {
  const AssetContentSource();

  static const String _kArticlesAsset = 'assets/content/articles.json';
  static const String _kVideosAsset = 'assets/content/videos.json';

  @override
  Future<List<Article>> loadArticles() async {
    final List<dynamic> raw = await _readJsonList(_kArticlesAsset);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Article.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<Video>> loadVideos() async {
    final List<dynamic> raw = await _readJsonList(_kVideosAsset);
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Video.fromJson)
        .toList(growable: false);
  }

  Future<List<dynamic>> _readJsonList(String assetPath) async {
    final String payload = await rootBundle.loadString(assetPath);
    final Object? decoded = jsonDecode(payload);
    return decoded is List ? decoded : const [];
  }
}
