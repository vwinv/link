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
