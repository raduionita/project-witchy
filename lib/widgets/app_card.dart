import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpacing.kMd), this.onTap, this.highlighted = false});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? Theme.of(context).colorScheme.surfaceContainerLow : AppColors.kSurfaceBase;
    final Widget content = Padding(padding: padding, child: child);
    final BorderRadius radius = BorderRadius.circular(AppSpacing.kRadiusM);
    return Material(
      color: bg,
      borderRadius: radius,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.kCard,
          border: highlighted ? const Border(bottom: BorderSide(color: AppColors.kCoral, width: 3)) : null,
        ),
        child: onTap != null ? InkWell(onTap: onTap, borderRadius: radius, child: content) : content,
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
      decoration: BoxDecoration(color: AppColors.kPrimary, borderRadius: BorderRadius.circular(AppSpacing.kRadiusM)),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: AppSpacing.kSm)],
          Expanded(child: DefaultTextStyle(style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) ?? const TextStyle(color: Colors.white), child: child)),
        ],
      ),
    );
  }
}
