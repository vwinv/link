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
    this.minSeats = 1,
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
      minSeats: json['minSeats'] as int? ?? 1,
    );
  }

  final String id;
  final String title;
  final String slug;
  final String? subtitle;
  final OfferEntitlements entitlements;
  final List<PremiumOfferPrice> prices;
  final int sortOrder;
  final int minSeats;

  OfferAudience get audience => entitlements.audience;
  bool get canCustomize => entitlements.canCustomize;
  int get maxTeamMembers => entitlements.maxTeamMembers;
  bool get hasPortfolio => entitlements.hasPortfolio;
  bool get hasWallet => entitlements.hasWallet;
  bool get hasAnalytics => entitlements.hasAnalytics;
  bool get hasVisitorInsights => entitlements.hasVisitorInsights;
  bool get hasSocialLinks => entitlements.hasSocialLinks;
  int get maxAiScans => entitlements.maxAiScans;
  int get maxShares => entitlements.maxShares;

  bool get hasPerSeatPricing =>
      audience.isTeam && prices.any((price) => price.isPerSeat);

  int get maxSelectableSeats {
    if (maxTeamMembers < 0) return 500;
    if (maxTeamMembers <= 0) return minSeats;
    return maxTeamMembers;
  }

  int get defaultSeats {
    // Toujours partir des sièges inclus ; on ne peut qu’ajouter des supplémentaires.
    return minSeats.clamp(1, maxSelectableSeats);
  }

  PremiumOfferPrice? get popularPrice {
    for (final price in prices) {
      if (price.isPopular) return price;
    }
    return prices.isNotEmpty ? prices.first : null;
  }

  PremiumOfferPrice? get monthlyPrice {
    for (final price in prices) {
      if (price.billingType.toUpperCase() == 'MONTHLY') return price;
    }
    return null;
  }

  PremiumOfferPrice? get yearlyPrice {
    for (final price in prices) {
      if (price.billingType.toUpperCase() == 'YEARLY') return price;
    }
    return null;
  }

  /// Prix affiché / sélectionné en priorité : annuel, sinon populaire, sinon premier.
  PremiumOfferPrice? get preferredPrice =>
      yearlyPrice ?? monthlyPrice ?? popularPrice;

  /// Ordre d’affichage des prix : annuel d’abord, puis le reste.
  List<PremiumOfferPrice> get pricesYearlyFirst {
    if (prices.length <= 1) return prices;
    final yearly = <PremiumOfferPrice>[];
    final others = <PremiumOfferPrice>[];
    for (final price in prices) {
      if (price.billingType.toUpperCase() == 'YEARLY') {
        yearly.add(price);
      } else {
        others.add(price);
      }
    }
    others.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return [...yearly, ...others];
  }
}
