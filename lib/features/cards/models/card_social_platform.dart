import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';

enum CardSocialPlatform {
  linkedin,
  instagram,
  whatsapp,
  x,
  facebook,
  website,
}

extension CardSocialPlatformX on CardSocialPlatform {
  static CardSocialPlatform fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'LINKEDIN':
        return CardSocialPlatform.linkedin;
      case 'INSTAGRAM':
        return CardSocialPlatform.instagram;
      case 'WHATSAPP':
        return CardSocialPlatform.whatsapp;
      case 'TWITTER':
        return CardSocialPlatform.x;
      case 'FACEBOOK':
        return CardSocialPlatform.facebook;
      case 'WEBSITE':
        return CardSocialPlatform.website;
      default:
        return CardSocialPlatform.linkedin;
    }
  }

  String get label {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return 'LinkedIn';
      case CardSocialPlatform.instagram:
        return 'Instagram';
      case CardSocialPlatform.whatsapp:
        return 'WhatsApp';
      case CardSocialPlatform.x:
        return 'X';
      case CardSocialPlatform.facebook:
        return 'Facebook';
      case CardSocialPlatform.website:
        return 'Site web';
    }
  }

  String get apiValue {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return 'LINKEDIN';
      case CardSocialPlatform.instagram:
        return 'INSTAGRAM';
      case CardSocialPlatform.whatsapp:
        return 'WHATSAPP';
      case CardSocialPlatform.x:
        return 'TWITTER';
      case CardSocialPlatform.facebook:
        return 'FACEBOOK';
      case CardSocialPlatform.website:
        return 'WEBSITE';
    }
  }

  String get placeholder {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return 'Votre URL LinkedIn';
      case CardSocialPlatform.instagram:
        return 'Votre @ Instagram';
      case CardSocialPlatform.whatsapp:
        return 'Votre numéro WhatsApp';
      case CardSocialPlatform.x:
        return 'Votre @ X';
      case CardSocialPlatform.facebook:
        return 'Votre URL Facebook';
      case CardSocialPlatform.website:
        return 'https://votre-site.com';
    }
  }

  Color get brandColor {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case CardSocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case CardSocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case CardSocialPlatform.x:
        return const Color(0xFF000000);
      case CardSocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case CardSocialPlatform.website:
        return const Color(0xFF1B4DFF);
    }
  }

  String? get iconAsset {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return AppAssets.linkedin;
      case CardSocialPlatform.instagram:
        return AppAssets.instagram;
      case CardSocialPlatform.whatsapp:
        return AppAssets.whatsapp;
      case CardSocialPlatform.x:
        return AppAssets.twitter;
      case CardSocialPlatform.facebook:
      case CardSocialPlatform.website:
        return null;
    }
  }

  String get brandLetter {
    switch (this) {
      case CardSocialPlatform.linkedin:
        return 'in';
      case CardSocialPlatform.instagram:
        return 'Ig';
      case CardSocialPlatform.whatsapp:
        return 'Wa';
      case CardSocialPlatform.x:
        return 'X';
      case CardSocialPlatform.facebook:
        return 'f';
      case CardSocialPlatform.website:
        return 'www';
    }
  }

  TextInputType get keyboardType {
    switch (this) {
      case CardSocialPlatform.whatsapp:
        return TextInputType.phone;
      case CardSocialPlatform.linkedin:
      case CardSocialPlatform.facebook:
      case CardSocialPlatform.website:
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  static String normalizeWebsiteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }
}
