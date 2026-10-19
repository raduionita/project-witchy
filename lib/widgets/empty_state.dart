import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'icon_badge.dart';

/// Shared empty, error or "needs more data" state: a badge, a title, an
/// explainer and an optional call to action. Every screen that can run out of
/// content uses this so the user always gets the same shape of message plus a
/// concrete next step instead of a dead end.
class EmptyState extends StatelessWidget {
  final FaIconData icon;
  final String title;
  final String message;

  /// Renders the button only when both the label and the callback are given.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Drops the outer padding when the state already sits in a scrollable that
  /// spaces its own children.
  final bool compact;
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction, this.compact = false});

  Widget _buildAction() {
    // AppButton is full width; cap it so a narrow column does not stretch it.
    return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 220), child: AppButton(label: actionLabel!, onTap: onAction));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: compact ? EdgeInsets.zero : const EdgeInsets.fromLTRB(8, 40, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(icon: icon, bg: AppColors.lav, fg: AppColors.pur, size: 44),
          const SizedBox(height: 12),
          Text(title, style: AppText.h2, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppText.sub, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[const SizedBox(height: 16), _buildAction()],
        ],
      ),
    );
  }
}
