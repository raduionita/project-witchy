/// Legal pages shown inside the in-app webview from the privacy gate.
abstract final class LegalLinks {
  static const String terms = 'https://qvonyx.com/witchy/terms.html';
  static const String privacy = 'https://qvonyx.com/witchy/privacy.html';
  static const String childProtection = 'https://qvonyx.com/witchy/child-protection.html';

  /// Builds the app route that opens [url] in the in-app webview.
  static String route(String title, String url) => Uri(path: '/webview', queryParameters: {'title': title, 'url': url}).toString();
}
