import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await action();
    if (!context.mounted) return;

    final AuthProvider auth = context.read<AuthProvider>();
    if (ok && auth.session != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authSignedIn)),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.kCanvas,
      appBar: AppBar(title: Text(l10n.settingsAccountTitle), backgroundColor: AppColors.kCanvas),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nights_stay_outlined, size: 20, color: AppColors.kPurple),
                SizedBox(width: 16),
                Icon(Icons.nights_stay_outlined, size: 20, color: AppColors.kPurple),
                SizedBox(width: 16),
                Icon(Icons.nights_stay_outlined, size: 20, color: AppColors.kGold),
                SizedBox(width: 16),
                Icon(Icons.nights_stay_outlined, size: 20, color: AppColors.kPurple),
                SizedBox(width: 16),
                Icon(Icons.nights_stay_outlined, size: 20, color: AppColors.kPurple),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.authSignInOptional, style: const TextStyle(fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: AppColors.kGold)),
            const SizedBox(height: 4),
            Text('Join the Coven', style: text.displaySmall?.copyWith(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(l10n.authBody, style: text.bodyMedium?.copyWith(color: AppColors.kMuted, fontSize: 11.5, height: 1.5)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: auth.busy ? null : () => _signIn(context, auth.signInWithGoogle),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton))),
              child: Text(l10n.authGoogleSignIn),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: auth.busy ? null : () => _signIn(context, auth.signInWithApple),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton))),
              child: Text(l10n.authAppleSignIn),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.kLine)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.nights_stay_outlined, size: 10, color: Color(0xFFA795B8))),
                const Expanded(child: Divider(color: AppColors.kLine)),
              ],
            ),
            TextButton(
              onPressed: auth.busy ? null : () => _signIn(context, auth.signInAnonymously),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton))),
              child: Text(l10n.authAnonymous),
            ),
            if (auth.busy) const SizedBox(height: AppSpacing.kMd),
            if (auth.busy) const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
          ],
        ),
      ),
    );
  }
}