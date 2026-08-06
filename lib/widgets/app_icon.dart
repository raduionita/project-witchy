import 'package:flutter/material.dart';

/// Icon sizes consistent with the app's spacing scale.
enum AppIconSize {
  small(16),
  medium(24),
  large(32),
  xl(48),
  huge(72);

  const AppIconSize(this.size);
  final double size;
}

/// Primary icon primitive used across Witchy.
///
/// Renders an [Icon] sized with [AppIconSize] and tinted with the active
/// [ColorScheme] role so icons stay consistent and theme-aware without
/// repeated styling.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIconSize.medium,
    this.color,
  });

  final IconData icon;

  /// Which sizing token to use.
  final AppIconSize size;

  /// Optional override; when null the icon uses the theme's default icon color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size.size,
      color: color ?? IconTheme.of(context).color,
    );
  }
}