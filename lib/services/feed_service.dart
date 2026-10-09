import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../models/article.dart';
import 'prefs_service.dart';

class FeedService {
  FeedService(this._prefs, {http.Client? client}) : _client = client ?? http.Client();

  final PrefsService _prefs;
  final http.Client _client;

  static const feedUrl = 'https://qvonyx.com/witchy/articles.xml';
  static const _timeout = Duration(seconds: 12);

  Future<List<Article>> load({bool refresh = false}) async {
    if (!refresh) {
      final cached = await _prefs.feedCache();
      if (cached != null && cached.isNotEmpty) return cached;
    }
    try {
      final response = await _client.get(Uri.parse(feedUrl)).timeout(_timeout);
      if (response.statusCode != 200) throw http.ClientException('Feed status ${response.statusCode}');
      final items = parseFeed(response.body);
      await _prefs.saveFeedCache(items);
      return items;
    } catch (_) {
      final cached = await _prefs.feedCache();
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  static List<Article> parseFeed(String body) {
    final document = XmlDocument.parse(body);
    return document.findAllElements('item').map((item) {
      return Article(
        title: item.getElement('title')?.innerText.trim() ?? '',
        link: item.getElement('link')?.innerText.trim() ?? '',
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

  static DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US').parse(raw).toUtc();
    } on FormatException {
      return DateTime.tryParse(raw);
    }
  }
}
