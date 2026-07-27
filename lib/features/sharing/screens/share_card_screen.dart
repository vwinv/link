import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/widgets/card_qr_display.dart';
import 'package:linkflutter/features/sharing/services/share_platform_service.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/providers/card_analytics_refresh_notifier.dart';
import 'package:provider/provider.dart';

class ShareCardScreen extends StatelessWidget {
  const ShareCardScreen({required this.card, super.key});

  final BusinessCard card;

  Future<void> _recordShare(BuildContext context, String method) async {
    await context.read<SharingApiService>().recordShare(
      cardId: card.id,
      method: method,
    );
    if (!context.mounted) return;
    context.read<CardAnalyticsRefreshNotifier>().requestRefresh(sharesDelta: 1);
  }

  Future<void> _shareWithSheet(
    BuildContext context, {
    required String method,
    String? subject,
  }) async {
    await _recordShare(context, method);
    if (!context.mounted) return;
    await SharePlatformService.shareRichLink(
      context,
      uri: ShareCardHelper.linkShareUri(card),
      subject: subject ?? ShareCardHelper.linkShareTitle(card),
    );
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final shared = await SharePlatformService.shareWhatsApp(
      context,
      url: ShareCardHelper.linkShareUrl(card),
    );
    if (!context.mounted || !shared) return;
    await _recordShare(context, 'WHATSAPP');
  }

  Future<void> _shareLink(BuildContext context) async {
    final copied = await SharePlatformService.copyLink(
      context,
      url: ShareCardHelper.publicUrl(card.slug),
    );
    if (!context.mounted || !copied) return;
    await _recordShare(context, 'LINK');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showAirDrop = !kIsWeb && Platform.isIOS;

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
              child: Row(
                children: [
                  if (showAirDrop)
                    Expanded(
                      child: _ShareOption(
                        label: l10n.shareOptionAirDrop,
                        backgroundColor: AppColors.bleu_primaire,
                        assetPath: AppAssets.onboardingAirdrop,
                        onTap: () =>
                            _shareWithSheet(context, method: 'AIRDROP'),
                      ),
                    ),
                  Expanded(
                    child: _ShareOption(
                      label: l10n.shareOptionMessage,
                      backgroundColor: const Color(0xFF2DBE8C),
                      icon: Icons.mail_outline_rounded,
                      onTap: () => _shareWithSheet(context, method: 'EMAIL'),
                    ),
                  ),
                  Expanded(
                    child: _ShareOption(
                      label: l10n.socialWhatsApp,
                      backgroundColor: const Color(0xFF25D366),
                      assetPath: AppAssets.whatsapp,
                      onTap: () => _shareWhatsApp(context),
                    ),
                  ),
                  Expanded(
                    child: _ShareOption(
                      label: ShareCardHelper.brandName,
                      assetPath: AppAssets.icone,
                      onTap: () => _shareLink(context),
                    ),
                  ),
                ],
              ),
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
