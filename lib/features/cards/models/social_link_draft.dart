import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';

class SocialLinkDraft {
  const SocialLinkDraft({
    required this.platform,
    this.isSelected = false,
    this.value = '',
  });

  final CardSocialPlatform platform;
  final bool isSelected;
  final String value;

  SocialLinkDraft copyWith({
    bool? isSelected,
    String? value,
  }) {
    return SocialLinkDraft(
      platform: platform,
      isSelected: isSelected ?? this.isSelected,
      value: value ?? this.value,
    );
  }

  static List<SocialLinkDraft> initialDefaults({CardKind? kind}) {
    final includeWebsite = kind?.isTeamLinked ?? false;
    return CardSocialPlatform.values
        .where(
          (platform) =>
              includeWebsite || platform != CardSocialPlatform.website,
        )
        .map((platform) => SocialLinkDraft(platform: platform))
        .toList();
  }
}
