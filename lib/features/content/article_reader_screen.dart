import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/article.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';

/// Full-screen reader for a single [Article].
class ArticleReaderScreen extends StatelessWidget {
  const ArticleReaderScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> paragraphs =
        article.body.split('\n\n').where((String p) => p.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contentArticle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kSm),
            Text(
              article.category,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (article.publishedAt != null) ...[
              const SizedBox(height: AppSpacing.kXs),
              Text(
                DateFormat('MMM d, yyyy').format(article.publishedAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.kMd),
            for (final String paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.kMd),
            ],
            AppCard(
              child: Text(
                l10n.contentArticleDisclaimer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}