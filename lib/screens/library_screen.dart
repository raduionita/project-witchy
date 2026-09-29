import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_text_field.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final articles = MockData.articles();
    return Scaffold(
      appBar: const AppTopBar(title: 'Apothecary Library'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const AppTextField(hint: 'Search spells, herbs, anatomy...', lead: AppIcons.search),
          const SizedBox(height: 12),
          for (final a in articles) ...[
            GestureDetector(
              onTap: () => context.go('/library/${a.id}'),
              child: AppCard(
                child: Row(
                  children: [
                    Container(width: 62, height: 62, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: a.thumb))),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(a.category, style: AppText.sans(8.5, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.0)),
                              Text(a.readTime, style: AppText.sans(9, c: AppColors.muted)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(a.title, style: AppText.serif(12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(a.excerpt, style: AppText.sans(10, c: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
