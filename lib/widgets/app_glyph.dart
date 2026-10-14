import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Renders either a Font Awesome [FaIconData] or a Material [IconData].
class AppGlyph extends StatelessWidget {
  final Object icon;
  final double? size;
  final Color? color;
  const AppGlyph(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final i = icon;
    if (i is FaIconData) return FaIcon(i, size: size, color: color);
    return Icon(i as IconData, size: size, color: color);
  }
}
