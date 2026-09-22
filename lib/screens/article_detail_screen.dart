import 'package:flutter/material.dart';

import '../models/witchy_models.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});
  @override
  Widget build(BuildContext context) {
    final a = article;
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Wellness Detail'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(colors: a.thumb)),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  WitchyTag(a.category),
                  Text(a.readTime, style: AppText.sans(9, c: const Color(0xFF8B7F95))),
                ]),
                const SizedBox(height: 6),
                Text(a.title, style: AppText.serif(18)),
                const SizedBox(height: 6),
                Text(a.excerpt, style: AppText.sub),
              ],
            ),
          ),
          WitchyCard(
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
