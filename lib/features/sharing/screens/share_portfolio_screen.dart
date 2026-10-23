import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/portfolio_stats.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/card_qr_display.dart';
import 'package:linkflutter/features/cards/widgets/portfolio_stats_sheet.dart';
import 'package:linkflutter/features/sharing/models/share_quota.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/providers/card_analytics_refresh_notifier.dart';
import 'package:provider/provider.dart';

/// Page « Portfolio publié » : lien, partages et aperçu sur la carte.
class SharePortfolioScreen extends StatefulWidget {
  const SharePortfolioScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<SharePortfolioScreen> createState() => _SharePortfolioScreenState();
}

class _SharePortfolioScreenState extends State<SharePortfolioScreen> {
  PortfolioOfferAccess _access = PortfolioOfferAccess.locked;
  bool _accessLoaded = false;
  bool _sharing = false;

  BusinessCard get card => widget.card;

  String get _publicUrl => ShareCardHelper.portfolioPublicUrl(card.slug);

  String get _displayUrl => _publicUrl.replaceFirst(RegExp(r'^https?://'), '');

  ShareQuota get _quota => _access.quota;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPortfolioAccess());
  }

  Future<void> _loadPortfolioAccess() async {
    final access = await loadPortfolioOfferAccess(context);
    if (!mounted) return;
    setState(() {
      _access = access;
      _accessLoaded = true;
    });
  }

  Future<void> _openPortfolioOffers() {
    return openLinkPremium(
      context,
      preferredAudience: OfferAudience.portfolio,
    );
  }

  Future<bool> _ensureCanShare() async {
    if (!_accessLoaded) await _loadPortfolioAccess();
    if (!mounted) return false;

    if (!_access.canShare) {
      await _openPortfolioOffers();
      return false;
    }
    return true;
  }

  Future<bool> _recordShare(String method) async {
    try {
      final updated = await context.read<SharingApiService>().recordShare(
            cardId: card.id,
            method: method,
            scope: 'portfolio',
          );
      if (!mounted) return false;
      if (updated != null) {
        setState(() {
          _access = PortfolioOfferAccess(
            canShare: updated.canShare,
            canCustomize: _access.canCustomize,
            hasAnalytics: _access.hasAnalytics,
            quota: updated,
          );
        });
      }
      context
          .read<CardAnalyticsRefreshNotifier>()
          .requestRefresh(sharesDelta: 1);
      return true;
    } on ApiException catch (error) {
      if (!mounted) return false;
      if (error.statusCode == 403) {
        setState(() {
          final max = _quota.max;
          _access = PortfolioOfferAccess(
            canShare: false,
            canCustomize: _access.canCustomize,
            hasAnalytics: _access.hasAnalytics,
            quota: ShareQuota(
              used: max > 0 ? max : _quota.used,
              max: max,
              canShare: false,
              isUnlimited: false,
            ),
          );
        });
        await _openPortfolioOffers();
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      return false;
    }
  }

  Future<void> _shareWithSheet(String method) async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    setState(() => _sharing = true);
    try {
      final recorded = await _recordShare(method);
      if (!mounted || !recorded) return;
      await SharePlatformService.shareRichLink(
        context,
        uri: ShareCardHelper.portfolioShareUri(card),
        subject: ShareCardHelper.portfolioShareTitle(card),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    setState(() => _sharing = true);
    try {
      final recorded = await _recordShare('WHATSAPP');
      if (!mounted || !recorded) return;
      await SharePlatformService.shareWhatsApp(
        context,
        url: _publicUrl,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _copyLink() async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    setState(() => _sharing = true);
    try {
      final recorded = await _recordShare('LINK');
      if (!mounted || !recorded) return;
      await SharePlatformService.copyLink(context, url: _publicUrl);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _showQr() async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    final recorded = await _recordShare('QR_CODE');
    if (!mounted || !recorded) return;

    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardQrDisplay(
                data: _publicUrl,
                size: 240,
                padding: 20,
                dotColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sharePortfolioQrHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.rs(AppFontSize.sm),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openStats() async {
    if (!await ensurePortfolioCapability(
      context,
      allowed: (access) => access.hasAnalytics,
    )) {
      return;
    }
    if (!mounted) return;
    var stats = PortfolioStats.empty;
    try {
      stats = await context.read<CardsApiService>().fetchPortfolioStats(card.id);
    } catch (_) {
      stats = PortfolioStats.empty;
    }
    if (!mounted) return;
    await showPortfolioStatsSheet(
      context,
      visits: stats.siteVisits,
      portfolioClicks: stats.portfolioClicks,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showAirDrop = !kIsWeb && Platform.isIOS;
    final portfolioBlocked = _accessLoaded && !_access.sharingIncluded;
    final quotaBlocked =
        _accessLoaded && _access.sharingIncluded && !_access.canShare;
    final blocked = !_accessLoaded || portfolioBlocked || quotaBlocked;
    final job = card.jobTitle?.trim() ?? '';
    final role = job.isNotEmpty ? job : card.subtitle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Text(
                      l10n.sharePortfolioPublishedTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(17),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  children: [
                    const Center(child: _PublishedMark()),
                    const SizedBox(height: 22),
                    Text(
                      l10n.sharePortfolioLiveTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(26),
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.sharePortfolioLiveBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(15),
                        height: 1.4,
                      ),
                    ),
                    if (portfolioBlocked) ...[
                      const SizedBox(height: 16),
                      _QuotaBlockedBanner(
                        message: l10n.sharePortfolioLockedHint,
                        ctaLabel: l10n.sharePortfolioLockedCta,
                        onUpgrade: _openPortfolioOffers,
                      ),
                    ] else if (quotaBlocked) ...[
                      const SizedBox(height: 16),
                      _QuotaBlockedBanner(
                        message: _quota.max > 0
                            ? l10n.shareQuotaReached(_quota.max)
                            : l10n.shareBlockedHint,
                        ctaLabel: l10n.sharePortfolioLockedCta,
                        onUpgrade: _openPortfolioOffers,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _LinkCopyRow(
                      url: portfolioBlocked || !_accessLoaded
                          ? l10n.sharePortfolioLinkLocked
                          : _displayUrl,
                      label: l10n.sharePortfolioCopy,
                      enabled: !blocked && !_sharing,
                      onCopy: _copyLink,
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: blocked || _sharing ? 0.45 : 1,
                      child: IgnorePointer(
                        ignoring: blocked || _sharing,
                        child: Row(
                          children: [
                            Expanded(
                              child: _ShareTile(
                                label: l10n.socialWhatsApp,
                                mark: 'WA',
                                markColor: const Color(0xFF1FA855),
                                background: const Color(0xFFE7F8EE),
                                onTap: _shareWhatsApp,
                              ),
                            ),
                            if (showAirDrop)
                              Expanded(
                                child: _ShareTile(
                                  label: l10n.shareOptionAirDrop,
                                  icon: Icons.wifi_tethering_rounded,
                                  markColor: AppColors.bleu_primaire,
                                  background: const Color(0xFFE8F1FB),
                                  onTap: () => _shareWithSheet('AIRDROP'),
                                ),
                              ),
                            Expanded(
                              child: _ShareTile(
                                label: l10n.shareOptionQr,
                                mark: 'QR',
                                markColor: AppColors.textPrimary,
                                background: const Color(0xFFF3F4F6),
                                onTap: _showQr,
                              ),
                            ),
                            Expanded(
                              child: _ShareTile(
                                label: l10n.shareOptionMessage,
                                icon: Icons.chat_bubble_outline_rounded,
                                markColor: const Color(0xFF1FA855),
                                background: const Color(0xFFE7F8EE),
                                onTap: () => _shareWithSheet('EMAIL'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _CardPreviewPanel(
                      previewLabel: l10n.sharePortfolioCardPreview,
                      name: card.fullName,
                      role: role,
                      avatarUrl: card.avatarImageUrl,
                      initials: card.initials,
                      viewLabel: l10n.sharePortfolioViewOnCard,
                      exchangeLabel: l10n.sharePortfolioExchange,
                    ),
                    const SizedBox(height: 18),
                    _StatsRow(
                      title: l10n.portfolioStatsTitle,
                      subtitle: l10n.sharePortfolioStatsRowHint,
                      onTap: _openStats,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublishedMark extends StatelessWidget {
  const _PublishedMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFE7F8EE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check_rounded,
        color: Color(0xFF22A35A),
        size: 36,
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _LinkCopyRow extends StatelessWidget {
  const _LinkCopyRow({
    required this.url,
    required this.label,
    required this.onCopy,
    required this.enabled,
  });

  final String url;
  final String label;
  final VoidCallback onCopy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(15),
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: enabled ? onCopy : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bleu_primaire,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.bleu_primaire.withValues(alpha: 0.4),
              disabledForegroundColor: AppColors.onPrimary,
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: AppFontWeight.semiBold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.label,
    required this.markColor,
    required this.background,
    required this.onTap,
    this.mark,
    this.icon,
  });

  final String label;
  final String? mark;
  final IconData? icon;
  final Color markColor;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: icon != null
                  ? Icon(icon, color: markColor, size: 26)
                  : Text(
                      mark ?? '',
                      style: TextStyle(
                        color: markColor,
                        fontSize: (mark ?? '').length > 2 ? 16 : 18,
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(12),
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPreviewPanel extends StatelessWidget {
  const _CardPreviewPanel({
    required this.previewLabel,
    required this.name,
    required this.role,
    required this.initials,
    required this.viewLabel,
    required this.exchangeLabel,
    this.avatarUrl,
  });

  final String previewLabel;
  final String name;
  final String role;
  final String? avatarUrl;
  final String initials;
  final String viewLabel;
  final String exchangeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111216),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            previewLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: AppFontWeight.semiBold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Avatar(url: avatarUrl, initials: initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? '—' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        role,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF3EC8FF), Color(0xFF7B6CFF)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  viewLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              exchangeLabel,
              style: const TextStyle(
                color: Color(0xFF111216),
                fontSize: 15,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.url});

  final String? url;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final image = url;
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF2A2C33),
      backgroundImage: image != null && image.isNotEmpty ? NetworkImage(image) : null,
      child: image != null && image.isNotEmpty
          ? null
          : Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: AppFontWeight.bold,
              ),
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(17),
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(13),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaire,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaBlockedBanner extends StatelessWidget {
  const _QuotaBlockedBanner({
    required this.message,
    required this.ctaLabel,
    required this.onUpgrade,
  });

  final String message;
  final String ctaLabel;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.rs(AppFontSize.sm),
                  height: 1.35,
                ),
              ),
            ),
            TextButton(
              onPressed: onUpgrade,
              child: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
