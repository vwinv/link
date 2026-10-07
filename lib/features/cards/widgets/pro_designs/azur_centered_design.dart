import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_team_line.dart';

/// Modèle Uni - fond uni, texte clair.
class AzurCenteredDesign extends StatelessWidget {
  const AzurCenteredDesign({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.companyName,
    this.address,
    this.logoUrl,
    this.avatarUrl,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String? companyName;
  final String? address;
  final String? avatarUrl;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final accent = template.accentColor;
    final heroSize = ProDesignMetrics.heroAvatarSize(context);

    const actions = [
      _ActionData(Icons.ios_share_rounded, 'Échanger mes coordonnées'),
      _ActionData(Icons.person_add_alt_1_rounded, 'Enregistrer le contact'),
      _ActionData(Icons.phone_rounded, 'M’appeler'),
      _ActionData(Icons.chat_bubble_outline_rounded, 'M’envoyer un message'),
      _ActionData(Icons.mail_outline_rounded, 'M’écrire par email'),
      // _ActionData(Icons.auto_awesome_rounded, 'Consulter mon portfolio'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: heroSize,
            height: heroSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.onPrimary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: ProDesignAvatar(
              size: heroSize,
              initials: initials,
              avatarUrl: avatarUrl,
              logoUrl: logoUrl,
              foregroundColor: accent,
              fontSize: ProDesignMetrics.heroAvatarTextSize(context),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          fullName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: ProDesignMetrics.heroTitleSize(context),
            fontWeight: AppFontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ProDesignTeamLine(
          jobTitle: subtitle,
          companyName: companyName,
          address: address,
          logoUrl: logoUrl,
          jobStyle: TextStyle(
            color: AppColors.onPrimary.withValues(alpha: 0.82),
            fontSize: context.rs(15),
            height: 1.35,
          ),
          companyStyle: TextStyle(
            color: AppColors.onPrimary,
            fontSize: context.rs(15),
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final action in actions) ...[
          _ActionButton(
            icon: action.icon,
            label: action.label,
            accent: accent,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'RÉSEAUX',
          style: TextStyle(
            color: AppColors.onPrimary.withValues(alpha: 0.72),
            fontSize: context.rs(12),
            fontWeight: AppFontWeight.semiBold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            _SocialIcon(asset: 'assets/linkedin.png'),
            SizedBox(width: AppSpacing.md),
            _SocialIcon(asset: 'assets/instagram.png'),
            SizedBox(width: AppSpacing.md),
            _SocialIcon(asset: 'assets/whatsapp.png'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _ActionData {
  const _ActionData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: context.rs(15),
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.onPrimary.withValues(alpha: 0.18),
        ),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
