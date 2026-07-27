enum OfferAudience {
  personal,
  team;

  static OfferAudience fromKey(String? value) {
    switch (value?.toUpperCase()) {
      case 'TEAM':
        return OfferAudience.team;
      default:
        return OfferAudience.personal;
    }
  }

  String get apiValue => name.toUpperCase();

  bool get isTeam => this == OfferAudience.team;
  bool get isPersonal => this == OfferAudience.personal;
}

class OfferEntitlements {
  const OfferEntitlements({
    required this.audience,
    required this.canCustomize,
    required this.maxTeamMembers,
    required this.hasPortfolio,
    required this.hasWallet,
    required this.hasAnalytics,
    required this.hasVisitorInsights,
    required this.hasSocialLinks,
    required this.maxAiScans,
  });

  factory OfferEntitlements.fromJson(Map<String, dynamic> json) {
    return OfferEntitlements(
      audience: OfferAudience.fromKey(json['audience'] as String?),
      canCustomize: json['canCustomize'] as bool? ?? false,
      maxTeamMembers: json['maxTeamMembers'] as int? ?? 0,
      hasPortfolio: json['hasPortfolio'] as bool? ?? false,
      hasWallet: json['hasWallet'] as bool? ?? false,
      hasAnalytics: json['hasAnalytics'] as bool? ?? false,
      hasVisitorInsights: json['hasVisitorInsights'] as bool? ?? false,
      hasSocialLinks: json['hasSocialLinks'] as bool? ?? false,
      maxAiScans: json['maxAiScans'] as int? ?? 0,
    );
  }

  static const none = OfferEntitlements(
    audience: OfferAudience.personal,
    canCustomize: false,
    maxTeamMembers: 0,
    hasPortfolio: false,
    hasWallet: false,
    hasAnalytics: false,
    hasVisitorInsights: false,
    hasSocialLinks: false,
    maxAiScans: 0,
  );

  final OfferAudience audience;
  final bool canCustomize;
  final int maxTeamMembers;
  final bool hasPortfolio;
  final bool hasWallet;
  final bool hasAnalytics;
  final bool hasVisitorInsights;
  final bool hasSocialLinks;
  final int maxAiScans;

  bool get hasUnlimitedAiScans => maxAiScans < 0;
  bool get hasUnlimitedTeamSeats => maxTeamMembers < 0;
  bool get hasTeamAccess => audience.isTeam && maxTeamMembers != 0;

  Map<String, dynamic> toJson() => {
        'audience': audience.apiValue,
        'canCustomize': canCustomize,
        'maxTeamMembers': maxTeamMembers,
        'hasPortfolio': hasPortfolio,
        'hasWallet': hasWallet,
        'hasAnalytics': hasAnalytics,
        'hasVisitorInsights': hasVisitorInsights,
        'hasSocialLinks': hasSocialLinks,
        'maxAiScans': maxAiScans,
      };
}
