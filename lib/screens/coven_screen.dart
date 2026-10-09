import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../navigation/app_nav.dart';
import '../services/feed_service.dart';
import '../services/prefs_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CovenScreen extends StatefulWidget {
  final FeedService? feed;
  const CovenScreen({super.key, this.feed});

  @override
  State<CovenScreen> createState() => _CovenScreenState();
}

class _CovenScreenState extends State<CovenScreen> {
  List<Article>? _articles;
  bool _loading = true;

  FeedService get _feed => widget.feed ?? FeedService(context.read<PrefsService>());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    try {
      final items = await _feed.load(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _articles = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _articles ??= [];
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
    return DateFormat('d MMM yyyy').format(date.toLocal());
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.pur));
    }
    final articles = _articles ?? const <Article>[];
    if (articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('The scroll is quiet', style: AppText.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('No wisdom could be gathered. Pull to try again.', style: AppText.sub, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.pur,
      backgroundColor: AppColors.card,
      onRefresh: () => _load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}
