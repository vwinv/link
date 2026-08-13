import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/widgets/card_qr_display.dart';
import 'package:linkflutter/features/sharing/models/share_quota.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/providers/card_analytics_refresh_notifier.dart';
import 'package:provider/provider.dart';

class ShareCardScreen extends StatefulWidget {
  const ShareCardScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  ShareQuota _quota = ShareQuota.empty;
  bool _quotaLoaded = false;
  bool _sharing = false;

  BusinessCard get card => widget.card;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuota());
  }

  Future<void> _loadQuota() async {
    try {
      final quota = await context.read<SharingApiService>().fetchQuota();
      if (!mounted) return;
      setState(() {
        _quota = quota;
        _quotaLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // En cas d’erreur réseau, on laisse tenter le partage (le serveur tranche).
        _quota = const ShareQuota(
          used: 0,
          max: -1,
          canShare: true,
          isUnlimited: true,
        );
        _quotaLoaded = true;
      });
    }
  }

  Future<bool> _ensureCanShare() async {
    if (!_quotaLoaded) await _loadQuota();
    if (!mounted) return false;

    if (!_quota.canShare) {
      await openLinkPremium(context);
      return false;
    }
    return true;
  }

  Future<bool> _recordShare(String method) async {
    try {
      final updated = await context.read<SharingApiService>().recordShare(
            cardId: card.id,
            method: method,
          );
      if (!mounted) return false;
      if (updated != null) {
        setState(() => _quota = updated);
      }
      context
          .read<CardAnalyticsRefreshNotifier>()
          .requestRefresh(sharesDelta: 1);
      return true;
    } on ApiException catch (error) {
      if (!mounted) return false;
      if (error.statusCode == 403) {
        setState(
          () => _quota = ShareQuota(
            used: _quota.max > 0 ? _quota.max : _quota.used,
            max: _quota.max,
            canShare: false,
            isUnlimited: false,
          ),
        );
        await openLinkPremium(context);
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      return false;
    }
  }

  Future<void> _shareWithSheet({
    required String method,
    String? subject,
  }) async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    setState(() => _sharing = true);
    try {
      final recorded = await _recordShare(method);
      if (!mounted || !recorded) return;
      await SharePlatformService.shareRichLink(
        context,
        uri: ShareCardHelper.linkShareUri(card),
        subject: subject ?? ShareCardHelper.linkShareTitle(card),
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
        url: ShareCardHelper.linkShareUrl(card),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareLink() async {
    if (_sharing) return;
    if (!await _ensureCanShare()) return;
    if (!mounted) return;

    setState(() => _sharing = true);
    try {
      final recorded = await _recordShare('LINK');
      if (!mounted || !recorded) return;
      await SharePlatformService.copyLink(
        context,
        url: ShareCardHelper.publicUrl(card.slug),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showAirDrop = !kIsWeb && Platform.isIOS;
    final blocked = _quotaLoaded && !_quota.canShare;
    final showQuotaChip =
        _quotaLoaded && !_quota.isUnlimited && _quota.max > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
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
                    l10n.shareCardTitle,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: context.rs(AppFontSize.lg),
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            if (showQuotaChip || blocked)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  0,
                ),
                child: blocked
                    ? _QuotaBlockedBanner(
                        message: _quota.max > 0
                            ? l10n.shareQuotaReached(_quota.max)
                            : l10n.shareBlockedHint,
                        ctaLabel: l10n.shareSeePremium,
                        onUpgrade: () => openLinkPremium(context),
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          l10n.shareQuotaUsed(_quota.used, _quota.max),
                          style: TextStyle(
                            color: AppColors.onPrimary.withValues(alpha: 0.55),
                            fontSize: context.rs(AppFontSize.sm),
                          ),
                        ),
                      ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.fullName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: context.rs(26),
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (card.subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        card.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onPrimary.withValues(alpha: 0.55),
                          fontSize: context.rs(AppFontSize.md),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    CardQrDisplay(
                      data: ShareCardHelper.publicUrl(card.slug),
                      size: 280,
                      padding: 24,
                      dotColor: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _LinkBrandBadge(),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 240,
                      child: Text(
                        l10n.shareCardQrHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onPrimary.withValues(alpha: 0.45),
                          fontSize: context.rs(AppFontSize.sm),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
              ),
              child: Opacity(
                opacity: blocked || _sharing ? 0.4 : 1,
                child: IgnorePointer(
                  ignoring: blocked || _sharing,
                  child: Row(
                    children: [
                      if (showAirDrop)
                        Expanded(
                          child: _ShareOption(
                            label: l10n.shareOptionAirDrop,
                            backgroundColor: AppColors.bleu_primaire,
                            assetPath: AppAssets.onboardingAirdrop,
                            onTap: () => _shareWithSheet(method: 'AIRDROP'),
                          ),
                        ),
                      Expanded(
                        child: _ShareOption(
                          label: l10n.shareOptionMessage,
                          backgroundColor: const Color(0xFF2DBE8C),
                          icon: Icons.mail_outline_rounded,
                          onTap: () => _shareWithSheet(method: 'EMAIL'),
                        ),
                      ),
                      Expanded(
                        child: _ShareOption(
                          label: l10n.socialWhatsApp,
                          backgroundColor: const Color(0xFF25D366),
                          assetPath: AppAssets.whatsapp,
                          onTap: _shareWhatsApp,
                        ),
                      ),
                      Expanded(
                        child: _ShareOption(
                          label: ShareCardHelper.brandName,
                          assetPath: AppAssets.icone,
                          onTap: _shareLink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      color: const Color(0xFF1A1C22),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.onPrimary.withValues(alpha: 0.9),
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

class _LinkBrandBadge extends StatelessWidget {
  const _LinkBrandBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppAssets.icone, width: 28, height: 28),
        const SizedBox(width: AppSpacing.sm),
        Text(
          ShareCardHelper.brandName,
          style: TextStyle(
            color: AppColors.onPrimary.withValues(alpha: 0.92),
            fontSize: context.rs(AppFontSize.md),
            fontWeight: AppFontWeight.semiBold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
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
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.icon,
    this.assetPath,
  });

  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final IconData? icon;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final hasTile = backgroundColor != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTile)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                alignment: Alignment.center,
                child: assetPath != null
                    ? Image.asset(
                        assetPath!,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      )
                    : Icon(icon, color: AppColors.onPrimary, size: 26),
              )
            else
              SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: assetPath != null
                      ? Image.asset(
                          assetPath!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        )
                      : Icon(icon, color: AppColors.onPrimary, size: 28),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 16,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.onPrimary.withValues(alpha: 0.92),
                    fontSize: context.rs(12),
                    fontWeight: AppFontWeight.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
