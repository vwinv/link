class PointsOverview {
  const PointsOverview({
    required this.referralCode,
    required this.balancePoints,
    required this.balanceFcfa,
    required this.fcfaPerPoint,
    required this.referralCount,
    required this.visitRewardPoints,
    required this.referralSubscribeRewardPoints,
    required this.ledger,
  });

  final String? referralCode;
  final double balancePoints;
  final double balanceFcfa;
  final int fcfaPerPoint;
  final int referralCount;
  final double visitRewardPoints;
  final double referralSubscribeRewardPoints;
  final List<PointsLedgerItem> ledger;

  factory PointsOverview.fromJson(Map<String, dynamic> json) {
    final rawLedger = json['ledger'];
    return PointsOverview(
      referralCode: json['referralCode'] as String?,
      balancePoints: (json['balancePoints'] as num?)?.toDouble() ?? 0,
      balanceFcfa: (json['balanceFcfa'] as num?)?.toDouble() ?? 0,
      fcfaPerPoint: (json['fcfaPerPoint'] as num?)?.toInt() ?? 10,
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      visitRewardPoints:
          (json['visitRewardPoints'] as num?)?.toDouble() ?? 0.1,
      referralSubscribeRewardPoints:
          (json['referralSubscribeRewardPoints'] as num?)?.toDouble() ?? 1,
      ledger: rawLedger is List
          ? rawLedger
              .whereType<Map>()
              .map(
                (row) => PointsLedgerItem.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class PointsLedgerItem {
  const PointsLedgerItem({
    required this.id,
    required this.amountPoints,
    required this.reason,
    this.productType,
    this.productRef,
    required this.createdAt,
  });

  final String id;
  final double amountPoints;
  final String reason;
  final String? productType;
  final String? productRef;
  final DateTime createdAt;

  factory PointsLedgerItem.fromJson(Map<String, dynamic> json) {
    return PointsLedgerItem(
      id: json['id'] as String? ?? '',
      amountPoints: (json['amountPoints'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String? ?? '',
      productType: json['productType'] as String?,
      productRef: json['productRef'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
