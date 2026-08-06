import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final ContentProvider provider = context.watch<ContentProvider>();

    if (!provider.loaded) {
      return const Center(child: Text('Loading library…'));
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
            child: Text(
              'Library',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setQuery,
              decoration: InputDecoration(
                hintText: 'Search articles and videos',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.kMd),
      child: SegmentedButton<ContentType?>(
        segments: const [
          ButtonSegment<ContentType?>(value: null, label: Text('All')),
          ButtonSegment<ContentType?>(
            value: ContentType.article,
            label: Text('Articles'),
          ),
          ButtonSegment<ContentType?>(
            value: ContentType.video,
            label: Text('Videos'),
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
    final List<String> categories = <String>['All', ...provider.categories];
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
                  item.type == ContentType.article ? 'Article' : 'Video',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
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
              'Nothing matches your search.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.kXs),
            Text(
              'Try a different keyword or clear the filters.',
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
