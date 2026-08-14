import 'package:linkflutter/l10n/app_localizations.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';

extension CardKindL10n on CardKind {
  String tagLabelL10n(AppLocalizations l10n) {
    switch (this) {
      case CardKind.personal:
        return l10n.cardKindPersonal;
      case CardKind.professional:
        return l10n.cardKindTeam;
      case CardKind.member:
        return l10n.cardKindMember;
    }
  }
}

extension CardSocialPlatformL10n on CardSocialPlatform {
  String labelL10n(AppLocalizations l10n) {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return l10n.socialLinkedIn;
      case CardSocialPlatform.instagram:
        return l10n.socialInstagram;
      case CardSocialPlatform.whatsapp:
        return l10n.socialWhatsApp;
      case CardSocialPlatform.x:
        return l10n.socialX;
      case CardSocialPlatform.facebook:
        return l10n.socialFacebook;
      case CardSocialPlatform.website:
        return l10n.socialWebsite;
    }
  }
}
