import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../l10n/app_localizations.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// Which provider authenticated this local session.
enum AuthProviderType { google, apple, anonymous }

/// Local-only authentication session.
///
/// The identity is obtained from the platform sign-in provider but is stored
/// **on-device** only (`shared_preferences`): no tokens, PII or cloud sync.
/// A future backend can reconcile users by [id] without storing credentials.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String id,
    required String displayName,
    String? email,
    required AuthProviderType provider,
    required DateTime signedInAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

/// Localized label for a sign-in provider.
String authProviderLabel(AppLocalizations l10n, AuthProviderType provider) =>
    switch (provider) {
      AuthProviderType.google => l10n.authProviderGoogle,
      AuthProviderType.apple => l10n.authProviderApple,
      AuthProviderType.anonymous => l10n.authProviderAnonymous,
    };
