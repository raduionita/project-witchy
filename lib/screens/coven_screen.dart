import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CovenScreen extends StatefulWidget {
  const CovenScreen({super.key});
  @override
  State<CovenScreen> createState() => _CovenScreenState();
}

class _CovenScreenState extends State<CovenScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final posts = MockData.posts();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'coven_post_fab',
        onPressed: () {},
        backgroundColor: Colors.transparent,
        hoverColor: AppColors.plum2,
        hoverElevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        elevation: 0,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.plumGradient, boxShadow: [AppColors.primaryShadow]),
          child: const FaIcon(AppIcons.plus, size: AppIconSize.base, color: AppColors.gold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.tabBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => tab = i),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: tab == i ? AppColors.plum : null, borderRadius: BorderRadius.circular(9)),
                        child: Text(
                          i == 0 ? 'Recent Whispers' : "Ancients' Wisdom",
                          style: AppText.sans(11, w: tab == i ? FontWeight.w600 : FontWeight.w500, c: tab == i ? Colors.white : AppColors.tabText),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final p in posts) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(initials: p.initials, size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.author, style: AppText.serif(12.5)), Text(p.meta, style: AppText.sans(9, c: AppColors.muted))]),
                      ),
                      AppTag(p.tag),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(p.body, style: AppText.sans(11, h: 1.55)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FaIcon(AppIcons.heart, size: AppIconSize.xs, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text('${p.likes}', style: AppText.sans(10.5, c: AppColors.muted)),
                      const SizedBox(width: 16),
                      FaIcon(AppIcons.chat, size: AppIconSize.xs, color: AppColors.muted),
                      const SizedBox(width: 5),
                      Text('${p.comments}', style: AppText.sans(10.5, c: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
