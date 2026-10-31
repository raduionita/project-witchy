/// In-app web content for the web build.
///
/// `webview_flutter` has no web implementation, so a web build embeds the page
/// in a real browser iframe and the reader never leaves the app. The native
/// builds keep using the platform webview and resolve to the stub.
library;

export 'in_app_web_frame_stub.dart' if (dart.library.js_interop) 'in_app_web_frame_web.dart';
