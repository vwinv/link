class CardAnalytics {
  const CardAnalytics({
    required this.views,
    required this.shares,
    required this.saved,
    this.uniqueVisitors = 0,
    this.periodDays = 7,
    this.periodViews = 0,
    this.previousPeriodViews = 0,
    this.viewsChangePercent = 0,
    this.viewsSeries = const [],
    this.sources = const [],
    this.sparklines = const CardAnalyticsSparklines.empty(),
  });

  factory CardAnalytics.fromJson(Map<String, dynamic> json) {
    final series = json['viewsSeries'] ?? json['views_series'];
    final sources = json['sources'];
    final sparklines = json['sparklines'];

    return CardAnalytics(
      views: _asInt(json['views']),
      shares: _asInt(json['shares']),
      saved: _asInt(json['saved']),
      uniqueVisitors: _asInt(json['uniqueVisitors'] ?? json['unique_visitors']),
      periodDays: _asInt(json['periodDays'] ?? json['period_days'], fallback: 7),
      periodViews: _asInt(json['periodViews'] ?? json['period_views']),
      previousPeriodViews: _asInt(
        json['previousPeriodViews'] ?? json['previous_period_views'],
      ),
      viewsChangePercent: _asInt(
        json['viewsChangePercent'] ?? json['views_change_percent'],
      ),
      viewsSeries: _parsePoints(series),
      sources: _parseSources(sources),
      sparklines: sparklines is Map
          ? CardAnalyticsSparklines.fromJson(
              Map<String, dynamic>.from(sparklines),
            )
          : const CardAnalyticsSparklines.empty(),
    );
  }

  static const empty = CardAnalytics(views: 0, shares: 0, saved: 0);

  final int views;
  final int shares;
  final int saved;
  final int uniqueVisitors;
  final int periodDays;
  final int periodViews;
  final int previousPeriodViews;
  final int viewsChangePercent;
  final List<CardAnalyticsPoint> viewsSeries;
  final List<CardAnalyticsSource> sources;
  final CardAnalyticsSparklines sparklines;

  CardAnalytics copyWith({
    int? views,
    int? shares,
    int? saved,
    int? uniqueVisitors,
    int? periodDays,
    int? periodViews,
    int? previousPeriodViews,
    int? viewsChangePercent,
    List<CardAnalyticsPoint>? viewsSeries,
    List<CardAnalyticsSource>? sources,
    CardAnalyticsSparklines? sparklines,
  }) {
    return CardAnalytics(
      views: views ?? this.views,
      shares: shares ?? this.shares,
      saved: saved ?? this.saved,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      periodDays: periodDays ?? this.periodDays,
      periodViews: periodViews ?? this.periodViews,
      previousPeriodViews: previousPeriodViews ?? this.previousPeriodViews,
      viewsChangePercent: viewsChangePercent ?? this.viewsChangePercent,
      viewsSeries: viewsSeries ?? this.viewsSeries,
      sources: sources ?? this.sources,
      sparklines: sparklines ?? this.sparklines,
    );
  }

  /// Builds a daily series for [start]..[end] (inclusive) from view timestamps.
  static List<CardAnalyticsPoint> buildSeries({
    required DateTime start,
    required DateTime end,
    List<DateTime> viewDates = const [],
  }) {
    var startDay = DateTime(start.year, start.month, start.day);
    var endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isBefore(startDay)) {
      final tmp = startDay;
      startDay = endDay;
      endDay = tmp;
    }

    final dayCount = endDay.difference(startDay).inDays + 1;
    final counts = <String, int>{};
    final days = <DateTime>[];
    for (var i = 0; i < dayCount; i++) {
      final day = startDay.add(Duration(days: i));
      days.add(day);
      counts[_dayKey(day)] = 0;
    }

    for (final viewedAt in viewDates) {
      final key = _dayKey(viewedAt);
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    final useWeekday = dayCount <= 7;
    return [
      for (final day in days)
        CardAnalyticsPoint(
          date: _dayKey(day),
          label: useWeekday ? _weekdayLabel(day) : _shortDateLabel(day),
          count: counts[_dayKey(day)] ?? 0,
        ),
    ];
  }

  static String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _weekdayLabel(DateTime date) {
    const labels = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return labels[date.weekday % 7];
  }

  static String _shortDateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}

class CardAnalyticsPoint {
  const CardAnalyticsPoint({
    required this.date,
    required this.label,
    required this.count,
  });

  factory CardAnalyticsPoint.fromJson(Map<String, dynamic> json) {
    return CardAnalyticsPoint(
      date: json['date'] as String? ?? '',
      label: json['label'] as String? ?? '',
      count: _asInt(json['count']),
    );
  }

  final String date;
  final String label;
  final int count;
}

class CardAnalyticsSource {
  const CardAnalyticsSource({
    required this.key,
    required this.count,
    required this.percent,
  });

  factory CardAnalyticsSource.fromJson(Map<String, dynamic> json) {
    return CardAnalyticsSource(
      key: json['key'] as String? ?? 'link',
      count: _asInt(json['count']),
      percent: _asInt(json['percent']),
    );
  }

  final String key;
  final int count;
  final int percent;
}

class CardAnalyticsSparklines {
  const CardAnalyticsSparklines({
    required this.views,
    required this.uniqueVisitors,
    required this.saved,
    required this.shares,
  });

  const CardAnalyticsSparklines.empty()
      : views = const [],
        uniqueVisitors = const [],
        saved = const [],
        shares = const [];

  factory CardAnalyticsSparklines.fromJson(Map<String, dynamic> json) {
    return CardAnalyticsSparklines(
      views: _asIntList(json['views']),
      uniqueVisitors: _asIntList(json['uniqueVisitors']),
      saved: _asIntList(json['saved']),
      shares: _asIntList(json['shares']),
    );
  }

  factory CardAnalyticsSparklines.fromSeries(List<int> views) {
    return CardAnalyticsSparklines(
      views: views,
      uniqueVisitors: [
        for (final v in views) (v * 0.4).round().clamp(0, 1 << 30),
      ],
      saved: [
        for (final v in views) (v * 0.2).round().clamp(0, 1 << 30),
      ],
      shares: [
        for (final v in views) (v * 0.15).round().clamp(0, 1 << 30),
      ],
    );
  }

  final List<int> views;
  final List<int> uniqueVisitors;
  final List<int> saved;
  final List<int> shares;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

List<int> _asIntList(dynamic value) {
  if (value is! List) return const [];
  return value.map(_asInt).toList();
}

List<CardAnalyticsPoint> _parsePoints(dynamic series) {
  if (series is! List) return const [];
  return series
      .whereType<Map>()
      .map((e) => CardAnalyticsPoint.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

List<CardAnalyticsSource> _parseSources(dynamic sources) {
  if (sources is! List) return const [];
  return sources
      .whereType<Map>()
      .map((e) => CardAnalyticsSource.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}
