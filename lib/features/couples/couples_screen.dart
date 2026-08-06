import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_card.dart';
import 'couples_provider.dart';
import 'models/couple_link.dart';

/// Placeholder Couples mode UI.
///
/// Real pairing requires a backend to exchange share codes between two
/// devices; that is explicitly deferred. This screen shows the local
/// placeholder link and clearly communicates that connectivity is coming.
class CouplesScreen extends StatelessWidget {
  const CouplesScreen({super.key});

  Future<void> _createLink(BuildContext context) async {
    final CoupleLink link =
        await context.read<CouplesProvider>().createLink();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).couplesYourLink(link.code),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CoupleLink? link = context.watch<CouplesProvider>().link;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.couplesTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kLg),
          children: [
            const Icon(
              Icons.favorite,
              size: 56,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: AppSpacing.kMd),
            Text(
              l10n.couplesComingSoon,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kSm),
            Text(
              l10n.couplesBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.kLg),
            if (link == null)
              FilledButton.icon(
                onPressed: () => _createLink(context),
                icon: const Icon(Icons.link),
                label: Text(l10n.couplesCreateLink),
              )
            else
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(l10n.couplesPlaceholderLink),
                      subtitle: Text(l10n.couplesLocalOnly),
                    ),
                    Text(
                      link.code,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.kSm),
                    Text(
                      l10n.couplesCreated(
                        DateFormatHelper.relative(l10n, link.createdAt),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small helper to avoid importing intl in this widget.
abstract final class DateFormatHelper {
  static String relative(AppLocalizations l10n, DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return l10n.relativeJustNow;
    if (diff.inHours < 1) return l10n.relativeMinutes(diff.inMinutes);
    if (diff.inDays < 1) return l10n.relativeHours(diff.inHours);
    return l10n.relativeDays(diff.inDays);
  }
}