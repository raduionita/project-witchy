import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.isLoading = false, this.variant = AppButtonVariant.primary, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget labelChild = isLoading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: AppColors.kGold), const SizedBox(width: AppSpacing.kSm)],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );
    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizing.kMinTouch),
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton)),
        ),
        child: labelChild,
      );
    }
    final BorderRadius radius = BorderRadius.circular(AppSpacing.kRadiusButton);
    return Opacity(
      opacity: onPressed == null && !isLoading ? 0.6 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.kPlum, borderRadius: radius, boxShadow: AppShadows.kButton),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizing.kMinTouch),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 13.5) ?? const TextStyle(color: Colors.white),
                    child: labelChild,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
