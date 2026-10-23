class PortfolioStats {
  const PortfolioStats({
    required this.siteVisits,
    required this.portfolioClicks,
  });

  factory PortfolioStats.fromJson(Map<String, dynamic> json) {
    return PortfolioStats(
      siteVisits: _asInt(json['siteVisits']),
      portfolioClicks: _asInt(json['portfolioClicks']),
    );
  }

  static const empty = PortfolioStats(siteVisits: 0, portfolioClicks: 0);

  final int siteVisits;
  final int portfolioClicks;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
