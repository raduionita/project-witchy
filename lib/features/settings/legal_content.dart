import '../../l10n/app_localizations.dart';

/// A titled section of a legal document.
class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

/// Locally supplied, curated Privacy Policy, localized via [l10n]. No
/// personal data is collected, stored, or transmitted by Witchy beyond what
/// you choose to log on-device.
List<LegalSection> kPrivacyPolicySections(AppLocalizations l10n) =>
    <LegalSection>[
      LegalSection(
        l10n.privacySec1Title,
        l10n.privacySec1Body,
      ),
      LegalSection(
        l10n.privacySec2Title,
        l10n.privacySec2Body,
      ),
      LegalSection(
        l10n.privacySec3Title,
        l10n.privacySec3Body,
      ),
      LegalSection(
        l10n.privacySec4Title,
        l10n.privacySec4Body,
      ),
      LegalSection(
        l10n.privacySec5Title,
        l10n.privacySec5Body,
      ),
      LegalSection(
        l10n.privacySec6Title,
        l10n.privacySec6Body,
      ),
    ];

/// Locally supplied, curated Terms of Service, localized via [l10n].
List<LegalSection> kTermsOfServiceSections(AppLocalizations l10n) =>
    <LegalSection>[
      LegalSection(
        l10n.termsSec1Title,
        l10n.termsSec1Body,
      ),
      LegalSection(
        l10n.termsSec2Title,
        l10n.termsSec2Body,
      ),
      LegalSection(
        l10n.termsSec3Title,
        l10n.termsSec3Body,
      ),
      LegalSection(
        l10n.termsSec4Title,
        l10n.termsSec4Body,
      ),
      LegalSection(
        l10n.termsSec5Title,
        l10n.termsSec5Body,
      ),
      LegalSection(
        l10n.termsSec6Title,
        l10n.termsSec6Body,
      ),
    ];
