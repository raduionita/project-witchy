/// Legal pages shown inside the in-app webview from the privacy gate.
abstract final class LegalLinks {
  static const String terms = 'https://witchy.qvonyx.com/terms';
  static const String privacy = 'https://witchy.qvonyx.com/privacy';
  static const String childProtection = 'https://witchy.qvonyx.com/child-protection';

  /// Builds the app route that opens [url] in the in-app webview.
  static String route(String title, String url) =>
      Uri(path: '/webview', queryParameters: {'title': title, 'url': url}).toString();
}
