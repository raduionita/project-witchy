import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final FaIconData? action;
  final VoidCallback? onAction;
  final FaIconData leading;
  final VoidCallback? onLeading;
  final bool badge;
  const AppTopBar({super.key, required this.title, this.action, this.onAction, this.leading = AppIcons.back, this.onLeading, this.badge = false});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    const box = BoxConstraints(minWidth: 34, minHeight: 34, maxWidth: 34, maxHeight: 34);
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            IconButton(
              onPressed: onLeading ?? () => context.back(),
              constraints: box,
              iconSize: AppIconSize.base,
              icon: FaIcon(leading, size: AppIconSize.base, color: AppColors.chipText),
            ),
            Expanded(child: Text(title, textAlign: TextAlign.center, style: AppText.appBar)),
            if (action != null)
              IconButton(
                onPressed: onAction,
                constraints: box,
                iconSize: AppIconSize.base,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FaIcon(action, size: AppIconSize.base, color: AppColors.pur),
                    if (badge)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            // IconButton(onPressed: onAction, constraints: box, iconSize: AppIconSize.base, icon: FaIcon(action ?? AppIcons.spark, size: AppIconSize.base, color: AppColors.pur)),
          ],
        ),
      ),
    );
  }
}
