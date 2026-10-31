import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common/legal_links.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/in_app_web_frame.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool _loadFailed = false;

  /// `assets/...` is a bundled page; anything else is fetched over the network.
  bool get _isAsset => widget.url.startsWith('assets/');

  /// Web builds have no platform webview, so the page is embedded in an iframe
  /// instead of handing it to a new browser tab.
  bool get _embedsOnWeb => kIsWeb && widget.url.isNotEmpty;

  /// Flutter serves bundled assets under an extra `assets/` prefix on the web.
  String get _embedUrl => _isAsset ? 'assets/${widget.url}' : widget.url;

  /// What an external browser tab has to load: the online mirror of a bundled
  /// page, or the URL itself when it is already remote.
  String get _browserUrl => LegalLinks.web(widget.url);

  void _fail() {
    if (mounted) setState(() => _loadFailed = true);
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(_browserUrl);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  void initState() {
    super.initState();
    // Web builds render through InAppWebFrame instead of a platform webview.
    if (kIsWeb || widget.url.isEmpty) return;
    _controller = (WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bg)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? true) _fail();
        },
      )));
    if (_isAsset) {
      _controller!.loadFlutterAsset(widget.url);
    } else {
      _controller!.loadRequest(Uri.parse(widget.url));
    }
  }

  Widget _buildPlaceholder() {
    if (widget.url.isEmpty) {
      return Center(child: Text('Nothing to show here', style: AppText.h2, textAlign: TextAlign.center));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This page couldn\u2019t load', style: AppText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(_isAsset ? 'The bundled copy could not be shown here.' : 'Open it in your browser:', style: AppText.sub, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Open in browser', onTap: _openInBrowser),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_embedsOnWeb) return InAppWebFrame(url: _embedUrl);
    final controller = _controller;
    if (controller != null && !_loadFailed) {
      return SizedBox.expand(child: WebViewWidget(controller: controller));
    }
    return _buildPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: widget.title),
      body: _buildBody(),
    );
  }
}
