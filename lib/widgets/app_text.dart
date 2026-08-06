import 'package:flutter/material.dart';

/// Typography variants resolved against the active [TextTheme].
enum AppTextVariant {
  /// Display heading (e.g. splash title).
  display,

  /// Screen header.
  headline,

  /// Section title.
  title,

  /// Standard body copy.
  body,

  /// Small caption / timestamps.
  caption,
}

/// Primary text primitive backing every paragraph in Witchy.
///
/// Wraps a [Text] using the app's typography tokens ([AppTextVariant]) plus
/// optional emphasis/color, so screens render consistent text without
/// repeating style boilerplate.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.body,
    this.style,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  /// The string to display.
  final String text;

  /// Which typography token to use.
  final AppTextVariant variant;

  /// Overrides applied on top of the resolved variant style.
  final TextStyle? style;

  /// Forces a color regardless of the resolved variant style.
  final Color? color;

  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  /// Resolves the [TextStyle] for [variant] against the active theme.
  TextStyle _style(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final TextStyle? spacing = switch (variant) {
      AppTextVariant.display => theme.displaySmall,
      AppTextVariant.headline => theme.headlineSmall,
      AppTextVariant.title => theme.titleMedium,
      AppTextVariant.body => theme.bodyMedium,
      AppTextVariant.caption => theme.bodySmall,
    };
    final TextStyle base = spacing ?? const TextStyle();
    final TextStyle styled = style == null ? base : base.merge(style);
    return color == null ? styled : styled.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      style: _style(context),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}