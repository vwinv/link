import 'package:linkflutter/features/cards/models/card_kind.dart';

enum CardBadgeType {
  personalTag,
  companyLogo;

  static CardBadgeType fromKey(String? key) {
    return CardBadgeType.values.firstWhere(
      (type) => type.name == key,
      orElse: () => CardBadgeType.personalTag,
    );
  }

  String optionSubtitleFor(CardKind kind) {
    switch (this) {
      case CardBadgeType.personalTag:
        if (kind.isMember) return 'Carte membre';
        return kind.isProfessional ? 'Carte équipe' : 'Carte perso';
      case CardBadgeType.companyLogo:
        return 'Logo entreprise';
    }
  }

  String pickerLabelFor(CardKind kind) {
    switch (this) {
      case CardBadgeType.personalTag:
        if (kind.isMember) return 'Carte membre';
        return kind.isProfessional ? 'Carte équipe' : 'Carte perso';
      case CardBadgeType.companyLogo:
        return 'Logo entreprise';
    }
  }
}
