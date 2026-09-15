import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.icon, this.isLoading = false, this.variant = AppButtonVariant.primary});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label);
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(AppSizing.kMinTouch),
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton)),
    );
    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: child,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizing.kMinTouch),
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton)),
        ),
      );
    }
    return FilledButton.icon(onPressed: isLoading ? null : onPressed, icon: Icon(icon ?? Icons.arrow_forward), label: child, style: style);
  }
}
