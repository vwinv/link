import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_team_line.dart';

/// Carte plein écran - modèle Degrade (dégradé + boutons glass).
class CorailGradientDesign extends StatelessWidget {
  const CorailGradientDesign({
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

    const secondaryActions = [
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
                  color: AppColors.onPrimary.withValues(alpha: 0.45),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: ProDesignAvatar(
              size: heroSize,
              initials: initials,
              avatarUrl: avatarUrl,
              logoUrl: logoUrl,
              foregroundColor: _accent,
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
            color: AppColors.onPrimary.withValues(alpha: 0.88),
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
        _PrimaryActionButton(
          icon: Icons.ios_share_rounded,
          label: 'Échanger mes coordonnées',
          accent: _accent,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final action in secondaryActions) ...[
          _GlassActionButton(
            icon: action.icon,
            label: action.label,
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
            _GlassSocialIcon(asset: 'assets/linkedin.png'),
            SizedBox(width: AppSpacing.md),
            _GlassSocialIcon(asset: 'assets/instagram.png'),
            SizedBox(width: AppSpacing.md),
            _GlassSocialIcon(asset: 'assets/whatsapp.png'),
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
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

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.onPrimary.withValues(alpha: 0.28),
        ),
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

class _GlassSocialIcon extends StatelessWidget {
  const _GlassSocialIcon({required this.asset});

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
          color: AppColors.onPrimary.withValues(alpha: 0.28),
        ),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
