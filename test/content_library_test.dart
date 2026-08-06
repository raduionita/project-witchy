import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/content/content_filter.dart';
import 'package:witchy/features/content/content_loader.dart';
import 'package:witchy/features/content/content_provider.dart';
import 'package:witchy/models/article.dart';
import 'package:witchy/models/video.dart';
import 'package:witchy/services/storage_service.dart';

class _FakeContentSource extends ContentSource {
  const _FakeContentSource();

  @override
  Future<List<Article>> loadArticles() async => const [
        Article(
          id: 'a1',
          title: 'Understanding the menstrual cycle',
          category: 'Cycle basics',
          body: 'body a1',
        ),
        Article(
          id: 'a2',
          title: 'Spotting early pregnancy signs',
          category: 'Pregnancy',
          body: 'body a2',
        ),
      ];

  @override
  Future<List<Video>> loadVideos() async => const [
        Video(
          id: 'v1',
          title: 'Cycle tracking made simple',
          category: 'Cycle basics',
          url: 'https://example.com/v1',
        ),
        Video(
          id: 'v2',
          title: 'Pregnancy ultrasound walkthrough',
          category: 'Pregnancy',
          url: 'https://example.com/v2',
        ),
      ];
}

Future<StorageService> _freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

List<ContentItem> _seed() => const [
      ContentItem(
        id: 'a1',
        title: 'Understanding the menstrual cycle',
        category: 'Cycle basics',
        type: ContentType.article,
      ),
      ContentItem(
        id: 'a2',
        title: 'Spotting early pregnancy signs',
        category: 'Pregnancy',
        type: ContentType.article,
      ),
      ContentItem(
        id: 'v1',
        title: 'Tracking made simple',
        category: 'Cycle basics',
        type: ContentType.video,
      ),
      ContentItem(
        id: 'v2',
        title: 'Pregnancy walkthrough',
        category: 'Pregnancy',
        type: ContentType.video,
      ),
    ];

void main() {
  group('filterContent', () {
    final List<ContentItem> items = _seed();

    test('returns everything with no filters', () {
      expect(filterContent(items: items), items);
    });

    test('filters by type', () {
      final List<ContentItem> videos =
          filterContent(items: items, type: ContentType.video);
      expect(videos.map((ContentItem i) => i.id), ['v1', 'v2']);
    });

    test('filters by category', () {
      final List<ContentItem> cycle =
          filterContent(items: items, category: 'Cycle basics');
      expect(cycle.map((ContentItem i) => i.id), ['a1', 'v1']);
    });

    test('filters by case-insensitive query on title', () {
      final List<ContentItem> pregnancy =
          filterContent(items: items, query: 'PREGNANCY');
      expect(pregnancy.map((ContentItem i) => i.id), ['a2', 'v2']);
    });

    test('combines type and query', () {
      final List<ContentItem> result = filterContent(
        items: items,
        type: ContentType.video,
        query: 'pregnancy',
      );
      expect(result.map((ContentItem i) => i.id), ['v2']);
    });

    test('ignores blank queries', () {
      expect(filterContent(items: items, query: '   '), items);
    });
  });

  group('contentCategories', () {
    test('dedupes and sorts categories', () {
      expect(contentCategories(_seed()), ['Cycle basics', 'Pregnancy']);
    });
  });

  group('ContentProvider', () {
    test('load populates catalog and visible content', () async {
      final ContentProvider provider = ContentProvider(
        await _freshStorage(),
        source: const _FakeContentSource(),
      );
      await provider.load();

      expect(provider.loaded, isTrue);
      expect(provider.articles, hasLength(2));
      expect(provider.videos, hasLength(2));
      expect(provider.visibleContent, hasLength(4));
      expect(provider.categories, ['Cycle basics', 'Pregnancy']);
    });

    test('filters by type and category through the provider', () async {
      final ContentProvider provider = ContentProvider(
        await _freshStorage(),
        source: const _FakeContentSource(),
      );
      await provider.load();

      provider.setTypeFilter(ContentType.article);
      expect(
        provider.visibleContent.map((ContentItem i) => i.id),
        ['a1', 'a2'],
      );

      provider.setCategory('Cycle basics');
      expect(
        provider.visibleContent.map((ContentItem i) => i.id),
        ['a1'],
      );
    });

    test('favorites toggle and persist across instances', () async {
      final StorageService storage = await _freshStorage();

      final ContentProvider first = ContentProvider(
        storage,
        source: const _FakeContentSource(),
      );
      await first.load();
      expect(first.isFavorite('a1'), isFalse);

      await first.toggleFavorite('a1');
      expect(first.isFavorite('a1'), isTrue);

      final ContentProvider second = ContentProvider(
        storage,
        source: const _FakeContentSource(),
      );
      await second.load();
      expect(second.isFavorite('a1'), isTrue);
      expect(second.isFavorite('a2'), isFalse);

      await second.toggleFavorite('a1');
      final ContentProvider third = ContentProvider(
        storage,
        source: const _FakeContentSource(),
      );
      await third.load();
      expect(third.isFavorite('a1'), isFalse);
    });
  });
}