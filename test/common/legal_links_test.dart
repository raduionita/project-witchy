import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/common/legal_links.dart';
import 'package:witchy/navigation/app_route_parser.dart';

void main() {
  group('LegalLinks', () {
    test('maps bundled assets to their online mirror', () {
      expect(LegalLinks.web(LegalLinks.terms), 'https://qvonyx.com/witchy/terms.html');
      expect(LegalLinks.web(LegalLinks.privacy), 'https://qvonyx.com/witchy/privacy.html');
      expect(LegalLinks.web(LegalLinks.childProtection), 'https://qvonyx.com/witchy/child-protection.html');
    });

    test('leaves remote URLs untouched', () {
      const article = 'https://qvonyx.com/witchy/articles/luteal-phase.html';
      expect(LegalLinks.web(article), article);
    });

    test('route keeps title and url readable by the router', () {
      final uri = Uri.parse(LegalLinks.route('Terms of Service', LegalLinks.terms));
      expect(uri.path, '/webview');
      expect(uri.queryParameters['title'], 'Terms of Service');
      expect(uri.queryParameters['url'], LegalLinks.terms);
    });
  });

  group('AppRouteParser', () {
    const parser = AppRouteParser();

    test('keeps the query so /webview deep links survive a reload', () async {
      final info = RouteInformation(uri: Uri.parse('/webview?title=Terms&url=assets/legal/terms.html'));
      expect(await parser.parseRouteInformation(info), '/webview?title=Terms&url=assets/legal/terms.html');
    });

    test('round-trips back to the same uri', () {
      const config = '/webview?title=Terms&url=assets/legal/terms.html';
      final restored = parser.restoreRouteInformation(config)!;
      expect(restored.uri.toString(), config);
    });
  });
}
