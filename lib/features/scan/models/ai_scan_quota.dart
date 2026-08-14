class AiScanQuota {
  const AiScanQuota({
    required this.used,
    required this.max,
    required this.canScan,
    required this.isUnlimited,
  });

  factory AiScanQuota.fromJson(Map<String, dynamic> json) {
    return AiScanQuota(
      used: json['used'] as int? ?? 0,
      max: json['max'] as int? ?? 0,
      canScan: json['canScan'] as bool? ?? false,
      isUnlimited: json['isUnlimited'] as bool? ?? false,
    );
  }

  static const empty = AiScanQuota(
    used: 0,
    max: 0,
    canScan: false,
    isUnlimited: false,
  );

  final int used;
  final int max;
  final bool canScan;
  final bool isUnlimited;

  String get displayLabel {
    if (isUnlimited) return 'Scans illimités';
    if (max <= 0) return 'Scan IA non inclus';
    return '$used / $max scans utilisés par mois';
  }
}
