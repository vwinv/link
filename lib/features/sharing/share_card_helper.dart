import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';

abstract final class ShareCardHelper {
  static const brandName = 'DropOne';

  static String publicUrl(String slug) => ApiConfig.publicPageUrl(slug);

  static Uri linkShareUri(BusinessCard card) => Uri.parse(publicUrl(card.slug));

  /// URL envoyée à WhatsApp pour déclencher l’aperçu riche.
  static String linkShareUrl(BusinessCard card) => publicUrl(card.slug);

  static String linkShareTitle(BusinessCard card) =>
      '${card.fullName} | $brandName Cartes de visite digitales';

  static const linkShareDescription = 'Découvrez ma carte de visite DropOne';

  /// Contenu texte brut (AirDrop, repli presse-papiers).
  static String cardContent(BusinessCard card) {
    final lines = <String>[
      'Carte de visite DropOne',
      '',
      card.fullName,
    ];

    if (card.subtitle.isNotEmpty) {
      lines.add(card.subtitle);
    }
    if (card.email != null && card.email!.trim().isNotEmpty) {
      lines.add('Email : ${card.email!.trim()}');
    }
    if (card.phone != null && card.phone!.trim().isNotEmpty) {
      lines.add('Téléphone : ${card.phone!.trim()}');
    }

    return lines.join('\n');
  }
}
