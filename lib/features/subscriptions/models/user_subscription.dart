import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';

class UserSubscription {
  const UserSubscription({
    required this.id,
    required this.status,
    required this.billingPeriod,
    required this.planName,
    required this.planSlug,
    required this.offerTitle,
    required this.offerSlug,
    this.billingType,
    required this.entitlements,
    this.currentPeriodEnd,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      status: json['status'] as String,
      billingPeriod: json['billingPeriod'] as String,
      planName: json['planName'] as String,
      planSlug: json['planSlug'] as String,
      offerTitle: json['offerTitle'] as String,
      offerSlug: json['offerSlug'] as String,
      billingType: json['billingType'] as String?,
      entitlements: json['entitlements'] is Map
          ? OfferEntitlements.fromJson(
              Map<String, dynamic>.from(json['entitlements'] as Map),
            )
          : OfferEntitlements.none,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
    );
  }

  final String id;
  final String status;
  final String billingPeriod;
  final String planName;
  final String planSlug;
  final String offerTitle;
  final String offerSlug;
  final String? billingType;
  final OfferEntitlements entitlements;
  final String? currentPeriodEnd;

  OfferAudience get audience => entitlements.audience;
  bool get canCustomize => entitlements.canCustomize;
  int get maxTeamMembers => entitlements.maxTeamMembers;
  bool get hasPortfolio => entitlements.hasPortfolio;
  int get maxAiScans => entitlements.maxAiScans;
  bool get hasTeamAccess => entitlements.hasTeamAccess;

  bool get isActive {
    if (status != 'ACTIVE' && status != 'TRIAL') return false;
    if (currentPeriodEnd == null) return true;

    final end = DateTime.tryParse(currentPeriodEnd!);
    if (end == null) return true;
    return end.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'billingPeriod': billingPeriod,
        'planName': planName,
        'planSlug': planSlug,
        'offerTitle': offerTitle,
        'offerSlug': offerSlug,
        'billingType': billingType,
        'entitlements': entitlements.toJson(),
        'currentPeriodEnd': currentPeriodEnd,
      };
}
