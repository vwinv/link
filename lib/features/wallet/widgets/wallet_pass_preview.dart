import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';

/// Aperçu Wallet : reprend le même rendu que la carte dans l’app (`CardPreview`).
class WalletPassPreview extends StatelessWidget {
  const WalletPassPreview({
    required this.card,
    super.key,
    this.companyLogoUrl,
    this.onLinkTap,
  });

  final BusinessCard card;
  final String? companyLogoUrl;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final style = card.theme.style;
    final qrData = ShareCardHelper.publicUrl(card.slug);

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: CardPreview(
            fullName: card.fullName,
            initials: card.initials,
            email: card.email ?? '',
            subtitle: card.subtitle,
            phone: card.phone,
            address: card.kind.isTeamLinked ? card.address : null,
            style: style,
            showQr: card.theme.showQrCode,
            qrData: qrData,
            avatarUrl: card.avatarImageUrl,
            companyLogoUrl: companyLogoUrl,
            cardBadge: card.theme.cardBadge,
            tagLabel: card.kind.tagLabel,
            avatarOnRight: true,
            avatarSize: 72,
            showDropOneLogo: card.isPersonal,
          ),
        ),
        if (onLinkTap != null) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onLinkTap,
            icon: Icon(
              Icons.link_rounded,
              color: style.accent,
              size: 18,
            ),
            label: Text(
              'Lien public',
              style: TextStyle(
                color: style.lightTheme
                    ? AppColors.textSecondary
                    : AppColors.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
