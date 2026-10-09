import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/services/feed_service.dart';
import 'package:witchy/services/prefs_service.dart';

const _fixtureXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Witchy Wisdom</title>
    <item>
      <title>Understanding Your Luteal Phase</title>
      <link>https://qvonyx.com/witchy/articles/luteal-phase.html</link>
      <description>&lt;p&gt;The autumn of your biology. Why emotions dip.&lt;/p&gt;</description>
      <category>Anatomy</category>
      <pubDate>Tue, 05 Oct 2026 08:00:00 GMT</pubDate>
    </item>
    <item>
      <title>Herbs for Somatic Cramp Relief</title>
      <link>https://qvonyx.com/witchy/articles/cramp-herbs.html</link>
      <description>Sip Mugwort and Raspberry Leaf.</description>
    </item>
    <item>
      <title></title>
      <link>https://qvonyx.com/witchy/articles/skipped.html</link>
    </item>
    <item>
      <title>No Link Item</title>
    </item>
  </channel>
</rss>
''';

void main() {
  late PrefsService prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  group('FeedService.parseFeed', () {
    test('parses items, strips HTML, defaults category, drops incomplete entries', () {
      final items = FeedService.parseFeed(_fixtureXml);

      expect(items, hasLength(2));
      expect(items[0].title, 'Understanding Your Luteal Phase');
      expect(items[0].link, 'https://qvonyx.com/witchy/articles/luteal-phase.html');
      expect(items[0].description, 'The autumn of your biology. Why emotions dip.');
      expect(items[0].category, 'ANATOMY');
      expect(items[0].pubDate, isNotNull);
      expect(items[0].pubDate!.isUtc, isTrue);
      expect(items[0].pubDate!.year, 2026);

      expect(items[1].title, 'Herbs for Somatic Cramp Relief');
      expect(items[1].category, 'GUIDE');
      expect(items[1].pubDate, isNull);
    });

    test('malformed xml throws', () {
      expect(() => FeedService.parseFeed('not xml'), throwsFormatException);
    });
  });

  group('FeedService cache', () {
    test('saveFeedCache and feedCache round-trip', () async {
      final items = FeedService.parseFeed(_fixtureXml);
      await prefs.saveFeedCache(items);

      final restored = await prefs.feedCache();
      expect(restored, isNotNull);
      expect(restored, hasLength(2));
      expect(restored![0].title, items[0].title);
      expect(restored[0].link, items[0].link);
      expect(restored[0].description, items[0].description);
      expect(restored[0].category, items[0].category);
      expect(restored[0].pubDate, items[0].pubDate);
      expect(restored[1].title, items[1].title);
      expect(restored[1].pubDate, isNull);
    });

    test('load without refresh serves the cache and skips the network', () async {
      final items = FeedService.parseFeed(_fixtureXml);
      await prefs.saveFeedCache(items);

      final loaded = await FeedService(prefs).load();
      expect(loaded, hasLength(2));
      expect(loaded[0].title, 'Understanding Your Luteal Phase');
    });

    test('load with empty cache and unreachable feed rethrows', () async {
      final client = MockClient((_) async => http.Response('', 503));
      await expectLater(FeedService(prefs, client: client).load(), throwsA(isA<Exception>()));
    });
  });
}
