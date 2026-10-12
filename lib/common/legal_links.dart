/// Legal pages shown inside the in-app webview from the privacy gate.
///
/// The pages ship inside the app under `assets/legal/` so the consent gate can
/// be read with no network. [web] maps a bundled asset to its online mirror,
/// which is what an external browser tab has to load.
abstract final class LegalLinks {
  static const String _host = 'https://qvonyx.com/witchy';

  static const String terms = 'assets/legal/terms.html';
  static const String privacy = 'assets/legal/privacy.html';
  static const String childProtection = 'assets/legal/child-protection.html';

  /// Absolute copy of [assetUrl] for opening outside the app; remote URLs pass through.
  static String web(String assetUrl) =>
      assetUrl.startsWith('assets/') ? '$_host/${assetUrl.split('/').last}' : assetUrl;

  /// Builds the app route that opens [url] in the in-app webview.
  static String route(String title, String url) => Uri(path: '/webview', queryParameters: {'title': title, 'url': url}).toString();
}
