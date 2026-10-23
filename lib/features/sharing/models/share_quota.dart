class ShareQuota {
  const ShareQuota({
    required this.used,
    required this.max,
    required this.canShare,
    required this.isUnlimited,
  });

  factory ShareQuota.fromJson(Map<String, dynamic> json) {
    return ShareQuota(
      used: json['used'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
      canShare: json['canShare'] as bool? ?? false,
      isUnlimited: json['isUnlimited'] as bool? ?? false,
    );
  }

  static const empty = ShareQuota(
    used: 0,
    max: 0,
    canShare: false,
    isUnlimited: false,
  );

  final int used;
  final int max;
  final bool canShare;
  final bool isUnlimited;
}

/// Capacités de l’offre Portfolio active.
class PortfolioOfferAccess {
  const PortfolioOfferAccess({
    required this.canShare,
    required this.canCustomize,
    required this.hasAnalytics,
    required this.quota,
  });

  factory PortfolioOfferAccess.fromJson(Map<String, dynamic> json) {
    final quota = json['quota'];
    return PortfolioOfferAccess(
      canShare: json['canShare'] == true,
      canCustomize: json['canCustomize'] == true,
      hasAnalytics: json['hasAnalytics'] == true,
      quota: quota is Map
          ? ShareQuota.fromJson(Map<String, dynamic>.from(quota))
          : ShareQuota.empty,
    );
  }

  static const locked = PortfolioOfferAccess(
    canShare: false,
    canCustomize: false,
    hasAnalytics: false,
    quota: ShareQuota.empty,
  );

  static const full = PortfolioOfferAccess(
    canShare: true,
    canCustomize: true,
    hasAnalytics: true,
    quota: ShareQuota(used: 0, max: -1, canShare: true, isUnlimited: true),
  );

  final bool canShare;
  final bool canCustomize;
  final bool hasAnalytics;
  final ShareQuota quota;

  /// L’offre inclut le partage (quota > 0 ou illimité).
  bool get sharingIncluded => quota.isUnlimited || quota.max > 0;
}
