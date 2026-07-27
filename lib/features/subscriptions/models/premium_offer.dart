import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer_price.dart';

class PremiumOffer {
  const PremiumOffer({
    required this.id,
    required this.title,
    required this.slug,
    this.subtitle,
    required this.entitlements,
    required this.prices,
    required this.sortOrder,
  });

  factory PremiumOffer.fromJson(Map<String, dynamic> json) {
    final pricesJson = json['prices'];
    final prices = <PremiumOfferPrice>[];
    if (pricesJson is List) {
      for (final item in pricesJson) {
        if (item is! Map) continue;
        prices.add(
          PremiumOfferPrice.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return PremiumOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      subtitle: json['subtitle'] as String?,
      entitlements: OfferEntitlements.fromJson(json),
      prices: prices,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  final String id;
  final String title;
  final String slug;
  final String? subtitle;
  final OfferEntitlements entitlements;
  final List<PremiumOfferPrice> prices;
  final int sortOrder;

  OfferAudience get audience => entitlements.audience;
  bool get canCustomize => entitlements.canCustomize;
  int get maxTeamMembers => entitlements.maxTeamMembers;
  bool get hasPortfolio => entitlements.hasPortfolio;
  bool get hasWallet => entitlements.hasWallet;
  bool get hasAnalytics => entitlements.hasAnalytics;
  bool get hasVisitorInsights => entitlements.hasVisitorInsights;
  bool get hasSocialLinks => entitlements.hasSocialLinks;
  int get maxAiScans => entitlements.maxAiScans;

  PremiumOfferPrice? get popularPrice {
    for (final price in prices) {
      if (price.isPopular) return price;
    }
    return prices.isNotEmpty ? prices.first : null;
  }
}
