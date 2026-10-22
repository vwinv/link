import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_analytics.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

enum _AnalyticsPeriod { days7, days30, custom }

class CardAnalyticsScreen extends StatefulWidget {
  const CardAnalyticsScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<CardAnalyticsScreen> createState() => _CardAnalyticsScreenState();
}

class _CardAnalyticsScreenState extends State<CardAnalyticsScreen> {
  late BusinessCard _card;
  var _period = _AnalyticsPeriod.days7;
  DateTimeRange? _customRange;
  var _isLoading = true;
  String? _error;
  CardAnalytics _analytics = CardAnalytics.empty;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<CardsApiService>();
      final bounds = _periodBounds();
      CardAnalytics analytics;
      if (_period == _AnalyticsPeriod.custom && _customRange != null) {
        analytics = await api.fetchCardAnalytics(
          _card.id,
          from: _customRange!.start,
          to: _customRange!.end,
        );
      } else {
        analytics = await api.fetchCardAnalytics(
          _card.id,
          days: _period == _AnalyticsPeriod.days30 ? 30 : 7,
        );
      }

      analytics = await _ensureSeries(api, analytics, bounds);

      if (!mounted) return;
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.cardAnalyticsLoadError;
        _isLoading = false;
      });
    }
  }

  (DateTime start, DateTime end) _periodBounds() {
    if (_period == _AnalyticsPeriod.custom && _customRange != null) {
      return (_customRange!.start, _customRange!.end);
    }
    final days = _period == _AnalyticsPeriod.days30 ? 30 : 7;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(Duration(days: days - 1));
    return (start, end);
  }

  Future<CardAnalytics> _ensureSeries(
    CardsApiService api,
    CardAnalytics analytics,
    (DateTime, DateTime) bounds,
  ) async {
    final (start, end) = bounds;
    if (analytics.viewsSeries.isNotEmpty) {
      final sparkline = analytics.sparklines.views.isNotEmpty
          ? analytics.sparklines
          : CardAnalyticsSparklines.fromSeries(
              analytics.viewsSeries.map((p) => p.count).toList(),
            );
      return analytics.copyWith(sparklines: sparkline);
    }

    List<DateTime> viewDates = const [];
    try {
      final visitors = await api.fetchCardVisitors(_card.id);
      viewDates = visitors.visitors.map((v) => v.viewedAt).toList();
    } catch (_) {
      // Keep empty dates - still show a chart for the period.
    }

    var series = CardAnalytics.buildSeries(
      start: start,
      end: end,
      viewDates: viewDates,
    );

    // Old API without daily series: show total views on the last day
    // so the chart is never blank when totals exist.
    final seriesTotal = series.fold<int>(0, (sum, p) => sum + p.count);
    if (seriesTotal == 0 && analytics.views > 0 && series.isNotEmpty) {
      final last = series.last;
      series = [
        ...series.sublist(0, series.length - 1),
        CardAnalyticsPoint(
          date: last.date,
          label: last.label,
          count: analytics.views,
        ),
      ];
    }

    final counts = series.map((p) => p.count).toList();
    final periodViews = counts.fold<int>(0, (sum, v) => sum + v);

    return analytics.copyWith(
      periodDays: series.length,
      periodViews:
          analytics.periodViews > 0 ? analytics.periodViews : periodViews,
      viewsSeries: series,
      sparklines: CardAnalyticsSparklines.fromSeries(counts),
    );
  }

  String _periodLabel(BuildContext context) {
    final l10n = context.l10n;
    if (_period == _AnalyticsPeriod.custom && _customRange != null) {
      final locale = Localizations.localeOf(context).toString();
      final fmt = DateFormat.MMMd(locale);
      return '${fmt.format(_customRange!.start)} - ${fmt.format(_customRange!.end)}';
    }
    return switch (_period) {
      _AnalyticsPeriod.days7 => l10n.cardAnalyticsPeriod7,
      _AnalyticsPeriod.days30 => l10n.cardAnalyticsPeriod30,
      _AnalyticsPeriod.custom => l10n.cardAnalyticsPeriodCustom,
    };
  }

  Future<void> _onPeriodSelected(_AnalyticsPeriod period) async {
    if (period == _AnalyticsPeriod.custom) {
      await _pickCustomRange();
      return;
    }
    if (_period == period && _customRange == null) return;
    setState(() {
      _period = period;
      _customRange = null;
    });
    await _load();
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initial = _customRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );

    final range = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _AnalyticsRangePopup(
        initialRange: initial,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
      ),
    );

    if (range == null || !mounted) return;
    setState(() {
      _period = _AnalyticsPeriod.custom;
      _customRange = DateTimeRange(
        start: DateTime(range.start.year, range.start.month, range.start.day),
        end: DateTime(range.end.year, range.end.month, range.end.day),
      );
    });
    await _load();
  }

  Future<void> _openVisitors() {
    return openCardVisitors(context, _card);
  }

  String _sourceLabel(String key) {
    final l10n = context.l10n;
    return switch (key) {
      'qr' => l10n.cardAnalyticsSourceQr,
      'share' => l10n.cardAnalyticsSourceShare,
      'app' => l10n.cardAnalyticsSourceApp,
      'nfc' || 'other' => l10n.cardAnalyticsSourceOther,
      _ => l10n.cardAnalyticsSourceLink,
    };
  }

  Color _sourceColor(String key) {
    return switch (key) {
      'qr' => AppColors.bleu_primaire,
      'share' => const Color(0xFF34C759),
      'app' => const Color(0xFF5AC8FA),
      'nfc' || 'other' => AppColors.textTertiaire,
      _ => const Color(0xFFFF9500),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final change = _analytics.viewsChangePercent;
    final changePositive = change >= 0;
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(_card.avatarImageUrl);
    final subtitle = [
      _card.kind.tagLabelL10n(l10n),
      if (_card.subtitle.isNotEmpty) _card.subtitle,
    ].join(' • ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.cardAnalyticsTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.lg),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.cardAnalyticsRealtimeTip)),
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xxl,
                  ),
                  children: [
                    _CardHeaderBanner(
                      fullName: _card.fullName,
                      initials: _card.initials,
                      subtitle: subtitle,
                      avatarUrl: avatarUrl,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cardAnalyticsTotalViews,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: context.rs(AppFontSize.sm),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_analytics.views}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: context.rs(40),
                                  fontWeight: AppFontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    changePositive
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    size: 16,
                                    color: changePositive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.cardAnalyticsWeekChange(
                                      changePositive
                                          ? '+$change'
                                          : '$change',
                                    ),
                                    style: TextStyle(
                                      color: changePositive
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontSize: context.rs(13),
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<_AnalyticsPeriod>(
                          onSelected: _onPeriodSelected,
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: _AnalyticsPeriod.days7,
                              child: Text(l10n.cardAnalyticsPeriod7),
                            ),
                            PopupMenuItem(
                              value: _AnalyticsPeriod.days30,
                              child: Text(l10n.cardAnalyticsPeriod30),
                            ),
                            PopupMenuItem(
                              value: _AnalyticsPeriod.custom,
                              child: Text(l10n.cardAnalyticsPeriodCustom),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.iconBgMuted,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 120),
                                  child: Text(
                                    _periodLabel(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: context.rs(13),
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _openVisitors,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.bleu_primaire,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.cardAnalyticsShowVisitors,
                                style: TextStyle(
                                  fontSize: context.rs(13),
                                  fontWeight: AppFontWeight.semiBold,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    else ...[
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.85,
                        children: [
                          _MetricTile(
                            icon: Icons.visibility_outlined,
                            iconColor: AppColors.bleu_primaire,
                            iconBackground: AppColors.bleu_clair,
                            label: l10n.cardAnalyticsTotalViews,
                            value: '${_analytics.views}',
                            sparkline: _analytics.sparklines.views,
                            sparklineColor: AppColors.bleu_primaire,
                          ),
                          _MetricTile(
                            icon: Icons.groups_outlined,
                            iconColor: AppColors.success,
                            iconBackground: AppColors.vert_clair,
                            label: l10n.cardAnalyticsUniqueVisitors,
                            value: '${_analytics.uniqueVisitors}',
                            sparkline: _analytics.sparklines.uniqueVisitors,
                            sparklineColor: AppColors.success,
                          ),
                          _MetricTile(
                            icon: Icons.bookmark_border_rounded,
                            iconColor: const Color(0xFFAF52DE),
                            iconBackground: const Color(0xFFF3E8FF),
                            label: l10n.cardAnalyticsSavedCards,
                            value: '${_analytics.saved}',
                            sparkline: _analytics.sparklines.saved,
                            sparklineColor: const Color(0xFFAF52DE),
                          ),
                          _MetricTile(
                            icon: Icons.ios_share_rounded,
                            iconColor: const Color(0xFFFF9500),
                            iconBackground: const Color(0xFFFFF1E0),
                            label: l10n.cardAnalyticsShares,
                            value: '${_analytics.shares}',
                            sparkline: _analytics.sparklines.shares,
                            sparklineColor: const Color(0xFFFF9500),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.cardAnalyticsViewsEvolution,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ViewsLineChart(points: _analytics.viewsSeries),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.cardAnalyticsDiscoverySources,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SourcesDonut(
                        sources: _analytics.sources,
                        labelBuilder: _sourceLabel,
                        colorBuilder: _sourceColor,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgMuted,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.textTertiaire,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.cardAnalyticsRealtimeTip,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: context.rs(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeaderBanner extends StatelessWidget {
  const _CardHeaderBanner({
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.avatarUrl,
  });

  final String fullName;
  final String initials;
  final String subtitle;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          if (url != null && url.isNotEmpty)
            ClipOval(
              child: Image.network(
                url,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _avatarFallback(),
              ),
            )
          else
            _avatarFallback(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: context.rs(AppFontSize.md),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                      fontSize: context.rs(12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bleu_primaire,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.onPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.bleu_primaire,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.sparkline,
    required this.sparklineColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final List<int> sparkline;
  final Color sparklineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(22),
                    fontWeight: AppFontWeight.bold,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.rs(11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 44,
            height: 28,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: sparkline,
                color: sparklineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewsLineChart extends StatelessWidget {
  const _ViewsLineChart({required this.points});

  final List<CardAnalyticsPoint> points;

  List<int> _labelIndexes(int count) {
    if (count <= 0) return const [];
    if (count <= 7) return List.generate(count, (i) => i);
    if (count <= 14) {
      return {0, for (var i = 3; i < count - 1; i += 3) i, count - 1}.toList()
        ..sort();
    }
    final step = (count / 5).floor().clamp(1, count);
    return {
      0,
      for (var i = step; i < count - 1; i += step) i,
      count - 1,
    }.toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final values = points.map((p) => p.count).toList();
    final labelIndexes = _labelIndexes(points.length);

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: points.isEmpty
          ? Center(
              child: Text(
                '-',
                style: TextStyle(
                  color: AppColors.textTertiaire,
                  fontSize: context.rs(14),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(values: values),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 18,
                  width: double.infinity,
                  child: Row(
                    children: [
                      for (var i = 0; i < points.length; i++)
                        Expanded(
                          child: labelIndexes.contains(i)
                              ? Text(
                                  points[i].label,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    color: AppColors.textTertiaire,
                                    fontSize: context.rs(10),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SourcesDonut extends StatelessWidget {
  const _SourcesDonut({
    required this.sources,
    required this.labelBuilder,
    required this.colorBuilder,
  });

  final List<CardAnalyticsSource> sources;
  final String Function(String key) labelBuilder;
  final Color Function(String key) colorBuilder;

  @override
  Widget build(BuildContext context) {
    final items = sources.isEmpty
        ? [
            const CardAnalyticsSource(key: 'link', count: 0, percent: 100),
          ]
        : sources;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _DonutPainter(
                slices: [
                  for (final source in items)
                    _DonutSlice(
                      value: source.percent.toDouble(),
                      color: colorBuilder(source.key),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                for (final source in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorBuilder(source.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            labelBuilder(source.key),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.rs(13),
                            ),
                          ),
                        ),
                        Text(
                          '${source.percent}%',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(13),
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;
    final maxValue = math.max(1, values.reduce(math.max)).toDouble();
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * (i / (values.length - 1));
      final y = size.height - (values[i] / maxValue) * size.height * 0.92;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || values.isEmpty) return;

    final maxValue = math.max(1, values.reduce(math.max)).toDouble();
    const topPad = 12.0;
    const bottomPad = 8.0;
    final chartHeight = math.max(1.0, size.height - topPad - bottomPad);

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.85)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = topPad + chartHeight * (1 - (i / 4));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset pointAt(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * (i / (values.length - 1));
      final ratio = values[i] / maxValue;
      final y = topPad + chartHeight * (1 - ratio);
      return Offset(x, y);
    }

    final points = <Offset>[
      for (var i = 0; i < values.length; i++) pointAt(i),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      linePath.lineTo(points[1].dx, points[1].dy);
      fillPath.lineTo(points[1].dx, points[1].dy);
    } else if (points.length > 2) {
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final dx = (p1.dx - p0.dx) / 3;
        linePath.cubicTo(p0.dx + dx, p0.dy, p1.dx - dx, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(p0.dx + dx, p0.dy, p1.dx - dx, p1.dy, p1.dx, p1.dy);
      }
    }

    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bleu_primaire.withValues(alpha: 0.30),
            AppColors.bleu_primaire.withValues(alpha: 0.03),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.bleu_primaire
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotFill = Paint()..color = AppColors.bleu_primaire;
    final dotStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotFill);
      canvas.drawCircle(point, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _DonutSlice {
  const _DonutSlice({required this.value, required this.color});

  final double value;
  final Color color;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices});

  final List<_DonutSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = AppColors.iconBgMuted,
      );
      canvas.drawCircle(center, radius * 0.62, Paint()..color = Colors.white);
      return;
    }

    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep,
        true,
        Paint()..color = slice.color,
      );
      start += sweep;
    }
    canvas.drawCircle(center, radius * 0.62, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _AnalyticsRangePopup extends StatefulWidget {
  const _AnalyticsRangePopup({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_AnalyticsRangePopup> createState() => _AnalyticsRangePopupState();
}

class _AnalyticsRangePopupState extends State<_AnalyticsRangePopup> {
  late DateTime _start;
  late DateTime _end;
  var _pickingEnd = false;

  @override
  void initState() {
    super.initState();
    _start = DateTime(
      widget.initialRange.start.year,
      widget.initialRange.start.month,
      widget.initialRange.start.day,
    );
    _end = DateTime(
      widget.initialRange.end.year,
      widget.initialRange.end.month,
      widget.initialRange.end.day,
    );
  }

  void _onDaySelected(DateTime day) {
    final selected = DateTime(day.year, day.month, day.day);
    setState(() {
      if (!_pickingEnd) {
        _start = selected;
        _end = selected;
        _pickingEnd = true;
      } else {
        if (selected.isBefore(_start)) {
          _end = _start;
          _start = selected;
        } else {
          _end = selected;
        }
        _pickingEnd = false;
      }
    });
  }

  String _rangeLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMd(locale);
    return '${fmt.format(_start)} - ${fmt.format(_end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cardAnalyticsPeriodCustom,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.rs(17),
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _rangeLabel(context),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.rs(13),
                  fontWeight: AppFontWeight.medium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColors.bleu_primaire,
                        onPrimary: AppColors.onPrimary,
                      ),
                ),
                child: CalendarDatePicker(
                  initialDate: _pickingEnd ? _end : _start,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  currentDate: DateTime.now(),
                  onDateChanged: _onDaySelected,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        DateTimeRange(start: _start, end: _end),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.bleu_primaire,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
