import 'package:linkflutter/features/cards/models/card_social_platform.dart';

class CardSocialLink {
  const CardSocialLink({
    required this.platform,
    required this.url,
  });

  factory CardSocialLink.fromJson(Map<String, dynamic> json) {
    return CardSocialLink(
      platform: CardSocialPlatformX.fromApiValue(json['platform'] as String?),
      url: (json['url'] as String? ?? '').trim(),
    );
  }

  final CardSocialPlatform platform;
  final String url;

  bool get isConfigured => url.isNotEmpty;
}
