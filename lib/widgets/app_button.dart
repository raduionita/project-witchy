import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  /// Shrinks to its content and uses tighter padding. Used for inline actions
  /// such as onboarding's Add past period.
  final bool compact;

  /// Optional icon shown before the label.
  final Widget? leading;
  const AppButton({super.key, required this.label, this.onTap, this.busy = false, this.compact = false, this.leading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: compact ? null : double.infinity,
        padding: compact ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9) : const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: AppColors.plumGradient, boxShadow: const [AppColors.primaryShadow]),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy) ...[const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)), const SizedBox(width: 8)],
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            // Flexible so a long label truncates instead of overflowing when the
            // button is given a narrow width (e.g. inside EmptyState).
            Flexible(child: Text(label, style: AppText.btn, overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
