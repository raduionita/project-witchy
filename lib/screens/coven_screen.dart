import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../models/article.dart';
import '../navigation/app_nav.dart';
import '../services/feed_service.dart';
import '../services/prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/empty_state.dart';

class CovenScreen extends StatefulWidget {
  final FeedService? feed;
  const CovenScreen({super.key, this.feed});

  @override
  State<CovenScreen> createState() => _CovenScreenState();
}

class _CovenScreenState extends State<CovenScreen> {
  List<Article>? _articles;
  bool _loading = true;

  /// True when the last network attempt failed. Paired with [_articles] it
  /// decides between the error state (nothing to show) and the stale banner
  /// (saved articles still on screen).
  bool _failed = false;

  /// True when [_articles] are the saved copy served after a failed refresh.
  bool _stale = false;

  FeedService get _feed => widget.feed ?? FeedService(context.read<PrefsService>());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    try {
      final result = await _feed.loadResult(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _articles = result.articles;
        _stale = result.stale;
        _failed = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Keep whatever is already on screen: a failed refresh must never
        // blank out articles the user is reading.
        _articles ??= [];
        _stale = false;
        _failed = true;
        _loading = false;
      });
    }
  }

  void _openArticle(Article article) {
    final title = Uri.encodeComponent(article.title);
    final url = Uri.encodeComponent(article.link);
    context.go('/webview?title=$title&url=$url');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return AppDate.dayMonthYear(date.toLocal());
  }

  /// Static placeholder blocks that match the shape of an article card, shown
  /// while the first load is in flight instead of a bare spinner.
  Widget _buildSkeletonCard() {
    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(height: height, decoration: BoxDecoration(color: AppColors.lav2, borderRadius: BorderRadius.circular(6))),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(0.28, 12),
          const SizedBox(height: 12),
          bar(0.85, 14),
          const SizedBox(height: 10),
          bar(0.6, 10),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      physics: const NeverScrollableScrollPhysics(),
      children: [for (var i = 0; i < 3; i++) ...[_buildSkeletonCard(), const SizedBox(height: 12)]],
    );
  }

  /// Banner shown when a refresh failed but saved articles are still visible.
  Widget _buildStaleBanner() {
    final gold = AppColors.readableOn(AppColors.gold, AppColors.goldBg);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.goldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
      child: Row(
        children: [
          FaIcon(AppIcons.alert, size: AppIconSize.sm, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Offline - showing saved articles, so a few may be out of date.', style: AppText.sans(10.5, c: AppColors.body, h: 1.4)),
          ),
          const SizedBox(width: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(onTap: () => _load(refresh: true), child: Text('Refresh', style: AppText.sans(10.5, w: FontWeight.w600, c: AppColors.pur))),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTag('About'),
          const SizedBox(height: 8),
          Text('Witchy', style: AppText.serif(14)),
          const SizedBox(height: 4),
          Text(
            'Witchy is a private, on-device period and cycle tracker. Your logs stay on this device - no account or cloud required.',
            style: AppText.sans(10.5, c: AppColors.muted, h: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildSkeleton();
    final articles = _articles ?? const <Article>[];
    return RefreshIndicator(
      color: AppColors.pur,
      backgroundColor: AppColors.card,
      onRefresh: () => _load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (articles.isEmpty) ...[
            EmptyState(
              icon: _failed ? AppIcons.alert : AppIcons.spark,
              title: 'No articles yet',
              message:
                  _failed
                      ? 'Articles could not be loaded. Check your connection, then try again.'
                      : 'New readings are published regularly. Pull down to check for them.',
              actionLabel: 'Try again',
              onAction: () => _load(refresh: true),
              compact: true,
            ),
            const SizedBox(height: 24),
          ] else ...[
            if (_stale) _buildStaleBanner(),
          ],
          for (final a in articles) ...[
            GestureDetector(
              onTap: () => _openArticle(a),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppTag(a.category),
                        if (a.pubDate != null) Text(_formatDate(a.pubDate), style: AppText.sans(9, c: AppColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(a.title, style: AppText.serif(14)),
                    if (a.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(a.description, style: AppText.sans(10.5, c: AppColors.muted, h: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Local info card - always last so the screen is never blank; not an article.
          _buildAboutCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}
