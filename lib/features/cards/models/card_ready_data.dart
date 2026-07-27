import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_draft.dart';

class CardReadyData {
  const CardReadyData({
    required this.cardId,
    required this.fullName,
    required this.initials,
    required this.email,
    this.phone,
    this.subtitle,
    this.tagLabel = 'Carte perso',
  });

  factory CardReadyData.fromCreateState({
    required BusinessCard card,
    required CardDraft draft,
    String tagLabel = 'Carte perso',
  }) {
    final job = card.jobTitle?.trim() ?? '';
    final company = card.company?.trim() ?? '';
    final subtitle = switch ((job.isEmpty, company.isEmpty)) {
      (true, true) => draft.subtitle,
      (true, false) => company,
      (false, true) => job,
      (false, false) => '$job · $company',
    };

    return CardReadyData(
      cardId: card.id,
      fullName: card.fullName.isNotEmpty ? card.fullName : draft.fullName,
      initials: draft.initials,
      email: card.email ?? draft.email,
      phone: card.phone ?? draft.phone,
      subtitle: subtitle.isEmpty ? null : subtitle,
      tagLabel: tagLabel,
    );
  }

  final String cardId;
  final String fullName;
  final String initials;
  final String email;
  final String? phone;
  final String? subtitle;
  final String tagLabel;
}
