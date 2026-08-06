import 'package:flutter/foundation.dart';

import '../../models/article.dart';
import '../../models/video.dart';
import '../../services/storage_service.dart';
import 'content_filter.dart';
import 'content_loader.dart';

/// Reactive facade over the seeded Content Library.
///
/// Loads the local catalog, tracks the current browse filter, and persists the
/// user's favorites (content IDs) through [StorageService]. Content itself is
/// shipped with the app — nothing personal is ever stored or transmitted.
class ContentProvider extends ChangeNotifier {
  ContentProvider(
    this._storage, {
    ContentSource source = const AssetContentSource(),
  }) : _source = source;

  static const String _kFavoritesKey = 'content.favorites';

  final StorageService _storage;
  final ContentSource _source;

  List<Article> _articles = const [];
  List<Video> _videos = const [];
  Set<String> _favoriteIds = <String>{};
  bool _loaded = false;

  ContentType? _typeFilter;
  String? _categoryFilter;
  String _query = '';

  /// Whether the catalog has been loaded from assets.
  bool get loaded => _loaded;

  List<Article> get articles => _articles;
  List<Video> get videos => _videos;

  /// Active content-type filter; null shows everything.
  ContentType? get typeFilter => _typeFilter;

  /// Active category filter; null shows every category.
  String? get categoryFilter => _categoryFilter;

  /// Active free-text search query.
  String get query => _query;

  /// The distinct categories across the catalog, sorted.
  List<String> get categories =>
      contentCategories(_allItems());

  /// Whether [id] is currently favorited.
  bool isFavorite(String id) => _favoriteIds.contains(id);

  /// Every item matching the active type/category/query filters.
  List<ContentItem> get visibleContent => filterContent(
        items: _allItems(),
        type: _typeFilter,
        category: _categoryFilter,
        query: _query,
      );

  /// Loads the catalog and persisted favorites.
  Future<void> load() async {
    if (_loaded) return;
    _articles = await _source.loadArticles();
    _videos = await _source.loadVideos();
    _favoriteIds = _storage
        .readList(_kFavoritesKey)
        .whereType<String>()
        .toSet();
    _loaded = true;
    notifyListeners();
  }

  /// Sets the active type filter (null clears it).
  void setTypeFilter(ContentType? type) {
    if (_typeFilter == type) return;
    _typeFilter = type;
    notifyListeners();
  }

  /// Sets the active category filter (null clears it).
  void setCategory(String? category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  /// Updates the free-text search query.
  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  /// Toggles the favorite state of [id] and persists the set.
  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _storage.writeList(_kFavoritesKey, _favoriteIds.toList());
    notifyListeners();
  }

  /// Looks up a seeded article by [id]; null when unknown.
  Article? articleById(String id) {
    for (final Article article in _articles) {
      if (article.id == id) return article;
    }
    return null;
  }

  /// Looks up a seeded video by [id]; null when unknown.
  Video? videoById(String id) {
    for (final Video video in _videos) {
      if (video.id == id) return video;
    }
    return null;
  }

  List<ContentItem> _allItems() => <ContentItem>[
        for (final Article article in _articles)
          ContentItem.fromArticle(article),
        for (final Video video in _videos) ContentItem.fromVideo(video),
      ];
}
