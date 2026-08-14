import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';

import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_team_line.dart';

/// Modèle Bubble - header découpé + bulle blanche ; seul le thème est variable.
class BubbleDesign extends StatelessWidget {
  const BubbleDesign({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.companyName,
    this.address,
    this.avatarUrl,
    this.logoUrl,
    this.showHeader = true,
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
  final bool showHeader;

  Color get _themeColor => template.themeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          BubbleHeaderSection(
            themeColor: _themeColor,
            initials: initials,
            avatarUrl: avatarUrl,
            logoUrl: logoUrl,
          ),
        if (showHeader) const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildContent(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    const actions = [
      _ActionData(Icons.ios_share_rounded, 'Échanger mes coordonnées'),
      _ActionData(Icons.person_add_alt_1_rounded, 'Enregistrer le contact'),
      _ActionData(Icons.phone_rounded, 'M’appeler'),
      _ActionData(Icons.chat_bubble_outline_rounded, 'M’envoyer un message'),
      _ActionData(Icons.mail_outline_rounded, 'M’écrire par email'),
      _ActionData(Icons.auto_awesome_rounded, 'Consulter mon portfolio'),
    ];

    return [
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
            themeColor: _themeColor,
          )
        else
          _MutedButton(
            icon: actions[i].icon,
            label: actions[i].label,
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
    ];
  }
}

/// Header Bubble : fond coloré découpé + avatar dans l’encoche.
class BubbleHeaderSection extends StatelessWidget {
  const BubbleHeaderSection({
    required this.themeColor,
    required this.initials,
    this.avatarUrl,
    this.logoUrl,
    this.topBar,
    this.topInset = 0,
    super.key,
  });

  final Color themeColor;
  final String initials;
  final String? avatarUrl;
  final String? logoUrl;
  final Widget? topBar;
  final double topInset;

  static const avatarRadius = 62.0;
  static const cornerRadius = 80.0;
  static const bodyHeight = 88.0;
  static const toolbarSlotHeight = 56.0;
  static const toolbarTopOffset = 12.0;

  double get _panelHeight =>
      (topBar != null
          ? topInset + toolbarTopOffset + toolbarSlotHeight
          : 0) +
      bodyHeight;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = ProDesignMetrics.headerAvatarRadius(context);
    final cornerRadius = context.rs(BubbleHeaderSection.cornerRadius);
    final panelHeight = _panelHeight;

    return SizedBox(
      height: panelHeight + avatarRadius,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: panelHeight,
            child: ClipPath(
              clipper: _BubbleHeaderClipper(
                cornerRadius: cornerRadius,
                avatarRadius: avatarRadius,
              ),
              child: ColoredBox(
                color: themeColor,
                child: Column(
                  children: [
                    if (topBar != null) ...[
                      SizedBox(height: topInset + context.rs(toolbarTopOffset)),
                      topBar!,
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: panelHeight - avatarRadius,
            left: 0,
            right: 0,
            child: Center(
              child: ProDesignAvatar(
                size: avatarRadius * 2,
                initials: initials,
              avatarUrl: avatarUrl,
                logoUrl: logoUrl,
                foregroundColor: themeColor,
                fontSize: ProDesignMetrics.heroAvatarTextSize(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleHeaderClipper extends CustomClipper<Path> {
  const _BubbleHeaderClipper({
    required this.cornerRadius,
    required this.avatarRadius,
  });

  final double cornerRadius;
  final double avatarRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;

    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height - cornerRadius);
    path.quadraticBezierTo(width, height, width - cornerRadius, height);
    path.lineTo(centerX + avatarRadius, height);
    path.arcToPoint(
      Offset(centerX - avatarRadius, height),
      radius: Radius.circular(avatarRadius),
      clockwise: false,
    );
    path.lineTo(cornerRadius, height);
    path.quadraticBezierTo(0, height, 0, height - cornerRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _BubbleHeaderClipper oldClipper) {
    return cornerRadius != oldClipper.cornerRadius ||
        avatarRadius != oldClipper.avatarRadius;
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
    required this.themeColor,
  });

  final IconData icon;
  final String label;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: themeColor,
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

class _MutedButton extends StatelessWidget {
  const _MutedButton({
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
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
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
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}
