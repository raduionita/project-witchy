import 'package:flutter/material.dart';

import '../models/article.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});
  @override
  Widget build(BuildContext context) {
    final a = article;
    return Scaffold(
      appBar: const AppTopBar(title: 'Wellness Detail'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: a.thumb)),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  AppTag(a.category),
                  Text(a.readTime, style: AppText.sans(9, c: const Color(0xFF8B7F95))),
                ]),
                const SizedBox(height: 6),
                Text(a.title, style: AppText.serif(18)),
                const SizedBox(height: 6),
                Text(a.excerpt, style: AppText.sub),
              ],
            ),
          ),
          AppCard(
            child: Text(
              'This guide blends evidence-based reproductive health with cycle-syncing ritual. Revisit the key signal from the library card above, then apply one small practice today — tea, rest, or breath — and log how your temple responds.',
              style: AppText.sans(11.5, h: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
