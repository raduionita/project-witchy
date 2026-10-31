import 'package:flutter/widgets.dart';

/// Mobile stand-in for [InAppWebFrame].
///
/// Native builds reach remote pages through `webview_flutter`, so this widget
/// is never built there. It exists only so the conditional export resolves on
/// non-web platforms.
class InAppWebFrame extends StatelessWidget {
  final String url;
  const InAppWebFrame({super.key, required this.url});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
