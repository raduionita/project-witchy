import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import 'auth_provider.dart';

/// Sign-in screen for the optional local account.
///
/// The account is optional: Witchy works fully offline and anonymously
/// without one. Signing in only enables optional features such as Couples
/// mode; the session stays on-device.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<void> _signIn(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final bool ok = await action();
    if (!context.mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    if (ok && auth.session != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in. Your account stays on this device.')),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
      return;
    }

    final String? error = auth.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.kLg),
          children: [
            Icon(
              Icons.favorite_outline,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.kMd),
            Text(
              'Sign in (optional)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.kSm),
            const Text(
              'Witchy never needs an account. Signing in gives you a '
              'consistent identity for features like Couples mode — '
              'everything stays on your device.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.kXl),
            FilledButton.icon(
              onPressed: auth.busy
                  ? null
                  : () => _signIn(context, auth.signInWithGoogle),
              icon: const Icon(FontAwesomeIcons.google),
              label: const Text('Continue with Google'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.kSm),
            OutlinedButton.icon(
              onPressed: auth.busy
                  ? null
                  : () => _signIn(context, auth.signInWithApple),
              icon: const Icon(FontAwesomeIcons.apple),
              label: const Text('Continue with Apple'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.kRadiusMd),
                ),
              ),
            ),
            if (auth.busy) const SizedBox(height: AppSpacing.kMd),
            if (auth.busy)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}