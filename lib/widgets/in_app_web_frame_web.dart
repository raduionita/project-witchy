import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Embeds [url] in a browser iframe so the web build shows the page inside the
/// app instead of handing it to a new browser tab.
///
/// The frame is sandboxed: scripts, forms and same-origin storage still work,
/// but the framed page cannot navigate the Flutter app away.
class InAppWebFrame extends StatefulWidget {
  final String url;
  const InAppWebFrame({super.key, required this.url});

  @override
  State<InAppWebFrame> createState() => _InAppWebFrameState();
}

class _InAppWebFrameState extends State<InAppWebFrame> {
  static int _nextView = 0;

  /// A factory can only be registered once per view type, so every screen gets
  /// its own type instead of re-registering on rebuild.
  final String _viewType = 'witchy-in-app-frame-${_nextView++}';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return web.HTMLIFrameElement()
        ..src = widget.url
        ..title = 'Article'
        ..setAttribute('sandbox', 'allow-scripts allow-same-origin allow-forms')
        ..setAttribute('allow', 'clipboard-write')
        ..setAttribute('referrerpolicy', 'no-referrer')
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
