import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import 'article_reader_screen.dart';
import 'content_filter.dart';
import 'content_provider.dart';
import 'video_detail_screen.dart';

/// The Content Library: browse, search, and filter locally seeded articles and
/// videos, and favorite the ones you want to return to.
class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ContentProvider provider = context.watch<ContentProvider>();

    if (!provider.loaded) {
      return Center(child: Text(l10n.contentLoading));
    }

    final List<ContentItem> visible = provider.visibleContent;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.kMd,
              AppSpacing.kMd,
              AppSpacing.kMd,
              AppSpacing.kSm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setQuery,
              decoration: InputDecoration(
                hintText: l10n.contentSearch,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.kSm),
          _typeSelector(context, provider),
          _categoryChips(context, provider),
          const SizedBox(height: AppSpacing.kSm),
          Expanded(
            child: visible.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.kMd),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.kSm),
                    itemBuilder: (BuildContext context, int index) =>
                        _contentCard(context, provider, visible[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _typeSelector(BuildContext context, ContentProvider provider) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd),
      child: SegmentedButton<ContentType?>(
        segments: <ButtonSegment<ContentType?>>[
          ButtonSegment<ContentType?>(value: null, label: Text(l10n.contentAll)),
          ButtonSegment<ContentType?>(
            value: ContentType.article,
            label: Text(l10n.contentArticles),
          ),
          ButtonSegment<ContentType?>(
            value: ContentType.video,
            label: Text(l10n.contentVideos),
          ),
        ],
        selected: <ContentType?>{provider.typeFilter},
        emptySelectionAllowed: true,
        onSelectionChanged: (Set<ContentType?> selection) =>
            provider.setTypeFilter(
              selection.isEmpty ? null : selection.first,
            ),
      ),
    );
  }

  Widget _categoryChips(BuildContext context, ContentProvider provider) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> categories = <String>[l10n.contentAll, ...provider.categories];
    final String? active = provider.categoryFilter;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.kMd,
          vertical: AppSpacing.kXs,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.kXs),
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          final bool selected =
              (index == 0 && active == null) || category == active;
          return FilterChip(
            label: Text(category),
            selected: selected,
            onSelected: (bool _) => provider.setCategory(
              index == 0 ? null : category,
            ),
          );
        },
      ),
    );
  }

  Widget _contentCard(
    BuildContext context,
    ContentProvider provider,
    ContentItem item,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool favorite = provider.isFavorite(item.id);

    return AppCard(
      onTap: () => _open(context, provider, item),
      child: Row(
        children: [
          Icon(
            item.type == ContentType.article
                ? Icons.menu_book_outlined
                : Icons.play_circle_outline,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.kMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.kXs),
                Text(
                  item.type == ContentType.article
                      ? l10n.contentArticle
                      : l10n.contentVideo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: favorite
                ? l10n.contentRemoveFavorite
                : l10n.contentAddFavorite,
            icon: Icon(
              favorite ? Icons.star : Icons.star_border,
              color: favorite ? scheme.tertiary : scheme.outline,
            ),
            onPressed: () => provider.toggleFavorite(item.id),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.kLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.kMd),
            Text(
              l10n.contentEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.kXs),
            Text(
              l10n.contentEmptyBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, ContentProvider provider, ContentItem item) {
    final Widget screen = switch (item.type) {
      ContentType.article => ArticleReaderScreen(
          article: provider.articleById(item.id)!,
        ),
      ContentType.video => VideoDetailScreen(
          video: provider.videoById(item.id)!,
        ),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
