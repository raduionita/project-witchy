import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      SnackBar(content: Text('Your link: ${link.code}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CoupleLink? link = context.watch<CouplesProvider>().link;

    return Scaffold(
      appBar: AppBar(title: const Text('Couples mode')),
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
              'Coming soon',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kSm),
            const Text(
              'Couples mode lets two partners share a private space for '
              'their cycle. Pairing needs a secure backend, which is still in '
              'development — nothing is shared yet, and your data stays '
              'on your device.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.kLg),
            if (link == null)
              FilledButton.icon(
                onPressed: () => _createLink(context),
                icon: const Icon(Icons.link),
                label: const Text('Create my share link'),
              )
            else
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('Your placeholder link'),
                      subtitle: const Text('Local only — not sent anywhere.'),
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
                      'Created ${DateFormatHelper.relative(link.createdAt)}',
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
  static String relative(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }
}