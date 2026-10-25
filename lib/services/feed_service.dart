import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../models/article.dart';
import 'prefs_service.dart';

/// One feed read: the articles plus whether they are the saved copy because
/// the network request failed. [stale] stays false for the normal offline-first
/// path (a cold start served straight from the cache) so no warning appears
/// until a refresh has actually failed.
class FeedResult {
  final List<Article> articles;
  final bool stale;
  const FeedResult(this.articles, {this.stale = false});
}

class FeedService {
  FeedService(this._prefs, {http.Client? client}) : _client = client ?? http.Client();

  final PrefsService _prefs;
  final http.Client _client;

  static const feedUrl = 'https://qvonyx.com/witchy/articles.xml';
  static const articleBase = 'https://qvonyx.com/witchy/articles/';
  static const _legacyArticleBase = 'https://qvonyx.com/witchy/';
  static const _timeout = Duration(seconds: 12);

  Future<List<Article>> load({bool refresh = false}) async => (await loadResult(refresh: refresh)).articles;

  /// Loads the feed, reporting whether the result is a stale cached copy.
  Future<FeedResult> loadResult({bool refresh = false}) async {
    if (!refresh) {
      final cached = await _prefs.feedCache();
      if (cached != null && cached.isNotEmpty) return FeedResult(await _normalizeCached(cached));
    }
    try {
      final response = await _client.get(Uri.parse(feedUrl)).timeout(_timeout);
      if (response.statusCode != 200) throw http.ClientException('Feed status ${response.statusCode}');
      final items = parseFeed(response.body);
      await _prefs.saveFeedCache(items);
      return FeedResult(items);
    } catch (_) {
      final cached = await _prefs.feedCache();
      if (cached != null && cached.isNotEmpty) return FeedResult(await _normalizeCached(cached), stale: true);
      rethrow;
    }
  }

  /// Rewrites links saved by older builds that resolved relative feed entries
  /// against `articles.xml`, which dropped the `/articles/` path segment.
  Future<List<Article>> _normalizeCached(List<Article> cached) async {
    var changed = false;
    final normalized = <Article>[];
    for (final article in cached) {
      final link = _normalizeLink(article.link);
      if (link != article.link) {
        changed = true;
        normalized.add(article.copyWith(link: link));
      } else {
        normalized.add(article);
      }
    }
    if (changed) await _prefs.saveFeedCache(normalized);
    return normalized;
  }

  static List<Article> parseFeed(String body) {
    final document = XmlDocument.parse(body);
    return document.findAllElements('item').map((item) {
      return Article(
        title: item.getElement('title')?.innerText.trim() ?? '',
        link: _resolveLink(item.getElement('link')?.innerText.trim() ?? ''),
        description: _stripHtml(item.getElement('description')?.innerText.trim() ?? ''),
        category: (item.getElement('category')?.innerText.trim() ?? 'GUIDE').toUpperCase(),
        pubDate: _parseDate(item.getElement('pubDate')?.innerText.trim() ?? ''),
      );
    }).where((a) => a.title.isNotEmpty && a.link.isNotEmpty).toList();
  }

  static String _stripHtml(String input) {
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return withoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Feed entries may be relative slugs - resolve them against the article
  // directory, not the RSS file itself.
  static String _resolveLink(String raw) {
    if (raw.isEmpty) return raw;
    final uri = Uri.tryParse(raw);
    if (uri == null) return raw;
    if (uri.hasScheme) return _normalizeLink(raw);
    return Uri.parse(articleBase).resolve(raw).toString();
  }

  static String _normalizeLink(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith(articleBase)) return raw;
    if (raw.startsWith(_legacyArticleBase)) {
      final tail = raw.substring(_legacyArticleBase.length);
      if (!tail.startsWith('articles/')) return '$articleBase$tail';
    }
    return raw;
  }

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(raw).toUtc();
    } on FormatException {
      return DateTime.tryParse(raw);
    }
  }
}
