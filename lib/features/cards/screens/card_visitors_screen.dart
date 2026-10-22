import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_visitors.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:provider/provider.dart';

/// Couleurs calées sur le mock « Card views ».
abstract final class _V {
  static const bg = Color(0xFFFFFFFF);
  static const searchFill = Color(0xFFF2F2F7);
  static const segmentBg = Color(0xFFF2F2F7);
  static const divider = Color(0xFFE5E5EA);
  static const meta = Color(0xFF8E8E93);
  static const subtitle = Color(0xFF6C6C70);
  static const chevron = Color(0xFFC7C7CC);
  static const dropOneBg = Color(0xFFE6F9F3);
  static const dropOneFg = Color(0xFF1B7A45);
  static const guestBg = Color(0xFFF2F2F7);
  static const blue = Color(0xFF0A6BFF);
  static const blueSoft = Color(0xFFE8F0FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFE7F6EC);
  static const purple = Color(0xFFAF52DE);
  static const purpleSoft = Color(0xFFF3E8FF);
  static const orange = Color(0xFFFF9500);
  static const orangeSoft = Color(0xFFFFF1E0);
}

class CardVisitorsScreen extends StatefulWidget {
  const CardVisitorsScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<CardVisitorsScreen> createState() => _CardVisitorsScreenState();
}

class _CardVisitorsScreenState extends State<CardVisitorsScreen> {
  final _searchController = TextEditingController();
  var _filter = CardVisitorFilter.all;
  var _isLoading = true;
  String? _error;
  CardVisitorsResult _result = CardVisitorsResult.empty;
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await context.read<CardsApiService>().fetchCardVisitors(
            widget.card.id,
            filter: _filter,
          );
      if (!mounted) return;
      setState(() {
        _result = result;
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
        _error = context.l10n.cardVisitorsLoadError;
        _isLoading = false;
      });
    }
  }

  void _setFilter(CardVisitorFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    _load();
  }

  List<CardVisitor> get _filteredVisitors {
    final q = _searchQuery;
    if (q.isEmpty) return _result.visitors;
    return _result.visitors.where((v) {
      return v.displayName.toLowerCase().contains(q) ||
          v.subtitle.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<CardVisitor>> _groupByDay(List<CardVisitor> visitors) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<CardVisitor>>{};

    for (final visitor in visitors) {
      final local = visitor.viewedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final label = day == today
          ? context.l10n.cardVisitorsToday
          : day == yesterday
              ? context.l10n.cardVisitorsYesterday
              : DateFormat.MMMMd(locale).format(day).toUpperCase();
      groups.putIfAbsent(label, () => []).add(visitor);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = _result.summary;
    final visitors = _filteredVisitors;
    final groups = _groupByDay(visitors);

    return Scaffold(
      backgroundColor: _V.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.cardVisitorsTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _V.blue,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    TextField(
                      controller: _searchController,
                      style: TextStyle(fontSize: context.rs(15)),
                      decoration: InputDecoration(
                        hintText: l10n.cardVisitorsSearchHint,
                        hintStyle: TextStyle(
                          color: _V.meta,
                          fontSize: context.rs(15),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _V.meta,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _V.searchFill,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.visibility_outlined,
                            iconColor: _V.blue,
                            iconBg: _V.blueSoft,
                            value: '${summary.views}',
                            label: l10n.cardVisitorsTotalViews,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.groups_outlined,
                            iconColor: _V.green,
                            iconBg: _V.greenSoft,
                            value: '${summary.uniqueVisitors}',
                            label: l10n.cardVisitorsUnique,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.bookmark_border_rounded,
                            iconColor: _V.purple,
                            iconBg: _V.purpleSoft,
                            value: '${summary.saved}',
                            label: l10n.cardVisitorsSaved,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.ios_share_rounded,
                            iconColor: _V.orange,
                            iconBg: _V.orangeSoft,
                            value: '${summary.shares}',
                            label: l10n.cardVisitorsShares,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SegmentBar(
                      filter: _filter,
                      views: summary.views,
                      dropOne: summary.dropOneCount,
                      guests: summary.guestCount,
                      onChanged: _setFilter,
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    else if (visitors.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          l10n.cardVisitorsEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.rs(15),
                          ),
                        ),
                      )
                    else
                      ...groups.entries.expand((entry) {
                        final items = entry.value;
                        return [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: _V.meta,
                                fontSize: context.rs(11),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          for (var i = 0; i < items.length; i++) ...[
                            _VisitorRow(
                              visitor: items[i],
                              onTap: () => openCardVisitorDetail(
                                context,
                                card: widget.card,
                                visitor: items[i],
                              ),
                            ),
                            if (i < items.length - 1)
                              const Divider(
                                height: 1,
                                thickness: 0.5,
                                color: _V.divider,
                              ),
                          ],
                          const SizedBox(height: 12),
                        ];
                      }),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.rs(18),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _V.subtitle,
              fontSize: context.rs(9),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.filter,
    required this.views,
    required this.dropOne,
    required this.guests,
    required this.onChanged,
  });

  final CardVisitorFilter filter;
  final int views;
  final int dropOne;
  final int guests;
  final ValueChanged<CardVisitorFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _V.segmentBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Seg(
              label: l10n.cardVisitorsFilterAll,
              count: views,
              selected: filter == CardVisitorFilter.all,
              color: _V.blue,
              badgeBg: _V.blueSoft,
              onTap: () => onChanged(CardVisitorFilter.all),
            ),
          ),
          Expanded(
            child: _Seg(
              label: l10n.cardVisitorsFilterDropOne,
              count: dropOne,
              selected: filter == CardVisitorFilter.dropone,
              color: _V.dropOneFg,
              badgeBg: _V.dropOneBg,
              onTap: () => onChanged(CardVisitorFilter.dropone),
            ),
          ),
          Expanded(
            child: _Seg(
              label: l10n.cardVisitorsFilterGuest,
              count: guests,
              selected: filter == CardVisitorFilter.guest,
              color: AppColors.textSecondary,
              badgeBg: const Color(0xFFE5E5EA),
              onTap: () => onChanged(CardVisitorFilter.guest),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    required this.badgeBg,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final Color badgeBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: context.rs(11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: context.rs(10),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisitorRow extends StatelessWidget {
  const _VisitorRow({required this.visitor, required this.onTap});

  final CardVisitor visitor;
  final VoidCallback onTap;

  bool get _isAnonymous =>
      !visitor.isDropOneUser && visitor.viewerUserId == null;

  IconData get _sourceIcon => switch (visitor.source) {
        'qr' => Icons.qr_code_2_rounded,
        'share' => Icons.reply_rounded,
        'app' => Icons.phone_iphone_rounded,
        'nfc' || 'other' => Icons.more_horiz_rounded,
        _ => Icons.link_rounded,
      };

  String _sourceLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (visitor.source) {
      'qr' => l10n.cardVisitorDetailMethodQr,
      'share' => l10n.cardVisitorDetailMethodShare,
      'app' => l10n.cardVisitorDetailMethodApp,
      'nfc' || 'other' => l10n.cardAnalyticsSourceOther,
      _ => l10n.cardVisitorDetailMethodLink,
    };
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(visitor.viewedAt.toLocal());
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(visitor.avatarUrl);
    final source = _sourceLabel(context);
    final middle = visitor.subtitle.isNotEmpty
        ? visitor.subtitle
        : (_isAnonymous ? source : '');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _Avatar(
              initials: visitor.initials,
              imageUrl: avatarUrl,
              anonymous: _isAnonymous,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          visitor.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (visitor.isDropOneUser) ...[
                        const SizedBox(width: 6),
                        const _DropOneBadge(),
                      ] else if (!_isAnonymous) ...[
                        const SizedBox(width: 6),
                        const _GuestBadge(),
                      ],
                    ],
                  ),
                  if (middle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      middle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _V.subtitle,
                        fontSize: context.rs(12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: _V.meta),
                      const SizedBox(width: 3),
                      Text(
                        time,
                        style: TextStyle(
                          color: _V.meta,
                          fontSize: context.rs(11),
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: TextStyle(
                          color: _V.meta,
                          fontSize: context.rs(11),
                        ),
                      ),
                      Icon(_sourceIcon, size: 12, color: _V.meta),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          source,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _V.meta,
                            fontSize: context.rs(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _V.blue, width: 1.5),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: _V.blue,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, size: 22, color: _V.chevron),
          ],
        ),
      ),
    );
  }
}

class _DropOneBadge extends StatelessWidget {
  const _DropOneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _V.dropOneBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: _V.dropOneFg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 8, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.cardVisitorsFilterDropOne,
            style: TextStyle(
              color: _V.dropOneFg,
              fontSize: context.rs(10),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestBadge extends StatelessWidget {
  const _GuestBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _V.guestBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.cardVisitorsFilterGuest,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: context.rs(10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.anonymous,
    this.imageUrl,
  });

  final String initials;
  final bool anonymous;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (anonymous) {
      return Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Color(0xFF8E8E93), size: 24),
      );
    }
    return CircleAvatar(
      radius: 23,
      backgroundColor: _V.blue,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
