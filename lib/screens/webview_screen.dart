import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_top_bar.dart';

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

  void _fail() {
    if (mounted) setState(() => _loadFailed = true);
  }

  @override
  void initState() {
    super.initState();
    // webview_flutter has no web implementation; web shows the placeholder.
    if (kIsWeb) return;
    _controller = (WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bg)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? true) _fail();
        },
      ))
      ..loadRequest(Uri.parse(widget.url)));
  }

  Widget _placeholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This page couldn\u2019t load', style: AppText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Open it in your browser:', style: AppText.sub, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            SelectableText(widget.url, style: AppText.sans(12.5, c: AppColors.pur), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final showWebView = controller != null && !_loadFailed;
    return Scaffold(
      appBar: AppTopBar(title: widget.title),
      body: showWebView ? SizedBox.expand(child: WebViewWidget(controller: controller)) : _placeholder(),
    );
  }
}
