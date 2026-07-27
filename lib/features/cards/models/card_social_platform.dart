import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';

enum CardSocialPlatform {
  linkedin,
  instagram,
  whatsapp,
  x,
  facebook,
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
    }
  }

  TextInputType get keyboardType {
    switch (this) {
      case CardSocialPlatform.whatsapp:
        return TextInputType.phone;
      case CardSocialPlatform.linkedin:
      case CardSocialPlatform.facebook:
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}
