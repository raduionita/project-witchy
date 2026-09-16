import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.kMd), this.onTap, this.highlighted = false, this.dark = false});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(AppSpacing.kRadiusM);
    if (dark && !isDark) {
      final Widget content = Padding(padding: padding, child: child);
      final Widget plum = DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.kPlum, borderRadius: radius, boxShadow: AppShadows.kButton),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: content),
      );
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        elevation: 0,
        child: onTap != null ? InkWell(onTap: onTap, borderRadius: radius, child: plum) : plum,
      );
    }
    final Color bg = isDark ? Theme.of(context).colorScheme.surfaceContainerLow : AppColors.kSurfaceBase;
    final Widget content = Padding(padding: padding, child: child);
    return Material(
      color: bg,
      borderRadius: radius,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.kLine),
          boxShadow: AppShadows.kCard,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: highlighted ? const Border(bottom: BorderSide(color: AppColors.kCoral, width: 3)) : null,
          ),
          child: onTap != null ? InkWell(onTap: onTap, borderRadius: radius, child: content) : content,
        ),
      ),
    );
  }
}

class AppInfoBanner extends StatelessWidget {
  const AppInfoBanner({super.key, required this.child, this.icon});

  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.kMd),
      decoration: BoxDecoration(gradient: AppGradients.kPlum, borderRadius: BorderRadius.circular(AppSpacing.kRadiusM), boxShadow: AppShadows.kButton),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: AppColors.kGold, size: 20), const SizedBox(width: AppSpacing.kSm)],
          Expanded(child: DefaultTextStyle(style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFE9D9F5)) ?? const TextStyle(color: Colors.white), child: child)),
        ],
      ),
    );
  }
}
