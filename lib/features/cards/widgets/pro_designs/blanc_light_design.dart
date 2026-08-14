import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_team_line.dart';

/// Modèle Blanc - fond clair, accents colorés.
class BlancLightDesign extends StatelessWidget {
  const BlancLightDesign({
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

  Color get _accent => template.accentColor;

  @override
  Widget build(BuildContext context) {
    final heroSize = ProDesignMetrics.heroAvatarSize(context);

    const actions = [
      _ActionData(Icons.ios_share_rounded, 'Échanger mes coordonnées'),
      _ActionData(Icons.person_add_alt_1_rounded, 'Enregistrer le contact'),
      _ActionData(Icons.phone_rounded, 'M’appeler'),
      _ActionData(Icons.chat_bubble_outline_rounded, 'M’envoyer un message'),
      _ActionData(Icons.mail_outline_rounded, 'M’écrire par email'),
      _ActionData(Icons.auto_awesome_rounded, 'Consulter mon portfolio'),
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
              color: _accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.28),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ProDesignAvatar(
              size: heroSize,
              initials: initials,
              avatarUrl: avatarUrl,
              logoUrl: logoUrl,
              backgroundColor: _accent,
              foregroundColor: AppColors.onPrimary,
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
            color: AppColors.textPrimary,
            fontSize: context.rs(28),
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
            color: AppColors.textSecondary,
            fontSize: context.rs(15),
            height: 1.35,
          ),
          companyStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.rs(15),
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < actions.length; i++) ...[
          if (i == 0)
            _PrimaryButton(
              icon: actions[i].icon,
              label: actions[i].label,
              accent: _accent,
            )
          else
            _OutlineButton(
              icon: actions[i].icon,
              label: actions[i].label,
              accent: _accent,
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'RÉSEAUX',
          style: TextStyle(
            color: AppColors.textTertiaire,
            fontSize: context.rs(12),
            fontWeight: AppFontWeight.semiBold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _SocialIcon(asset: 'assets/linkedin.png', accent: _accent),
            const SizedBox(width: AppSpacing.md),
            _SocialIcon(asset: 'assets/instagram.png', accent: _accent),
            const SizedBox(width: AppSpacing.md),
            _SocialIcon(asset: 'assets/whatsapp.png', accent: _accent),
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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
        color: accent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.onPrimary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.onPrimary,
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

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
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
  const _SocialIcon({required this.asset, required this.accent});

  final String asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
