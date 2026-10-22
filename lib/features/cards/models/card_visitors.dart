class CardVisitorsSummary {
  const CardVisitorsSummary({
    required this.views,
    required this.uniqueVisitors,
    required this.saved,
    required this.shares,
    required this.dropOneCount,
    required this.guestCount,
  });

  factory CardVisitorsSummary.fromJson(Map<String, dynamic> json) {
    return CardVisitorsSummary(
      views: _asInt(json['views']),
      uniqueVisitors: _asInt(json['uniqueVisitors']),
      saved: _asInt(json['saved']),
      shares: _asInt(json['shares']),
      dropOneCount: _asInt(json['dropOneCount']),
      guestCount: _asInt(json['guestCount']),
    );
  }

  static const empty = CardVisitorsSummary(
    views: 0,
    uniqueVisitors: 0,
    saved: 0,
    shares: 0,
    dropOneCount: 0,
    guestCount: 0,
  );

  final int views;
  final int uniqueVisitors;
  final int saved;
  final int shares;
  final int dropOneCount;
  final int guestCount;
}

enum CardVisitorFilter { all, dropone, guest }

extension CardVisitorFilterApi on CardVisitorFilter {
  String get apiValue => switch (this) {
        CardVisitorFilter.all => 'all',
        CardVisitorFilter.dropone => 'dropone',
        CardVisitorFilter.guest => 'guest',
      };
}

class CardVisitor {
  const CardVisitor({
    required this.id,
    required this.viewedAt,
    required this.isDropOneUser,
    required this.source,
    required this.displayName,
    required this.subtitle,
    required this.initials,
    required this.hasSaved,
    required this.hasShared,
    this.avatarUrl,
    this.viewerUserId,
    this.viewerCardSlug,
    this.durationSeconds,
    this.locationLabel,
    this.deviceLabel,
  });

  factory CardVisitor.fromJson(Map<String, dynamic> json) {
    return CardVisitor(
      id: json['id'] as String,
      viewedAt: DateTime.tryParse(json['viewedAt'] as String? ?? '') ??
          DateTime.now(),
      isDropOneUser: json['isDropOneUser'] as bool? ?? false,
      source: json['source'] as String? ?? 'link',
      displayName: json['displayName'] as String? ?? 'Visiteur',
      subtitle: json['subtitle'] as String? ?? '',
      initials: json['initials'] as String? ?? '?',
      avatarUrl: json['avatarUrl'] as String?,
      viewerUserId: json['viewerUserId'] as String?,
      viewerCardSlug: json['viewerCardSlug'] as String?,
      hasSaved: json['hasSaved'] as bool? ?? false,
      hasShared: json['hasShared'] as bool? ?? false,
      durationSeconds: _asNullableInt(json['durationSeconds']),
      locationLabel: json['locationLabel'] as String?,
      deviceLabel: json['deviceLabel'] as String?,
    );
  }

  final String id;
  final DateTime viewedAt;
  final bool isDropOneUser;
  final String source;
  final String displayName;
  final String subtitle;
  final String initials;
  final String? avatarUrl;
  final String? viewerUserId;
  final String? viewerCardSlug;
  final bool hasSaved;
  final bool hasShared;
  final int? durationSeconds;
  final String? locationLabel;
  final String? deviceLabel;
}

class CardVisitorsResult {
  const CardVisitorsResult({
    required this.summary,
    required this.visitors,
  });

  factory CardVisitorsResult.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'];
    final list = json['visitors'];
    return CardVisitorsResult(
      summary: summaryJson is Map
          ? CardVisitorsSummary.fromJson(Map<String, dynamic>.from(summaryJson))
          : CardVisitorsSummary.empty,
      visitors: list is List
          ? list
              .whereType<Map>()
              .map((e) => CardVisitor.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  static const empty = CardVisitorsResult(
    summary: CardVisitorsSummary.empty,
    visitors: [],
  );

  final CardVisitorsSummary summary;
  final List<CardVisitor> visitors;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}
