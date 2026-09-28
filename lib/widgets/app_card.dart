import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.dark = false, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    if (dark) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: AppColors.plumGradient),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      );
    }
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [BoxShadow(color: Color(0x0A2B0A3D), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: child,
    );
  }
}
