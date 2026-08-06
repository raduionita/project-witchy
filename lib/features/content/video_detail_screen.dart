import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/video.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

/// Detail screen for a single [Video], offering a way to open it externally.
class VideoDetailScreen extends StatelessWidget {
  const VideoDetailScreen({super.key, required this.video});

  final Video video;

  Future<void> _open(BuildContext context) async {
    final Uri? uri = Uri.tryParse(video.url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).contentVideoError),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contentVideo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kMd),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    size: AppSpacing.kXl * 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.kMd),
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.kSm),
                  Text(
                    video.category,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  if (video.publishedAt != null) ...[
                    const SizedBox(height: AppSpacing.kXs),
                    Text(
                      DateFormat('MMM d, yyyy').format(video.publishedAt!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.kMd),
            if (video.description != null) ...[
              Text(
                video.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.kLg),
            ],
            AppButton(
              label: l10n.contentWatch,
              icon: Icons.play_arrow,
              onPressed: () => _open(context),
            ),
          ],
        ),
      ),
    );
  }
}