import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_team_line.dart';

/// Modèle Arc - fond coloré + carte blanche margée à coins supérieurs arrondis.
class ArcDesign extends StatelessWidget {
  const ArcDesign({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    this.companyName,
    this.address,
    this.logoUrl,
    this.avatarUrl,
    this.topBar,
    this.topInset = 0,
    this.expand = false,
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
  final Widget? topBar;
  final double topInset;
  final bool expand;

  static const avatarRadius = 62.0;
  static const avatarBorderWidth = 8.0;
  static const topCornerRadius = 50.0;
  static const sheetMarginHorizontal = AppSpacing.xl;
  static const sheetMarginTop = AppSpacing.xl;
  static const toolbarSlotHeight = 56.0;
  static const toolbarTopOffset = 12.0;
  static const bandBelowToolbar = 32.0;
  static const compactBandHeight = 108.0;

  Color get _themeColor => template.themeColor;

  double get _coloredBandHeight {
    if (topBar != null) {
      return topInset +
          toolbarTopOffset +
          toolbarSlotHeight +
          bandBelowToolbar;
    }
    return compactBandHeight;
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = ProDesignMetrics.headerAvatarRadius(context);
    final borderWidth = context.rs(ArcDesign.avatarBorderWidth);
    final avatarOuterSize = avatarRadius * 2 + borderWidth * 2;
    final whiteCardTop = _coloredBandHeight + context.rs(sheetMarginTop);
    final avatarTop = whiteCardTop - avatarRadius - borderWidth;
    final sheetInsets = EdgeInsets.fromLTRB(
      context.rs(sheetMarginHorizontal),
      whiteCardTop,
      context.rs(sheetMarginHorizontal),
      0,
    );
    final cornerRadius = context.rs(topCornerRadius);

    final avatar = Container(
      width: avatarOuterSize,
      height: avatarOuterSize,
      decoration: const BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ProDesignAvatar(
          size: avatarRadius * 2,
          initials: initials,
              avatarUrl: avatarUrl,
          logoUrl: logoUrl,
          backgroundColor: _themeColor,
          foregroundColor: AppColors.onPrimary,
          fontSize: ProDesignMetrics.heroAvatarTextSize(context),
        ),
      ),
    );

    final sheetContent = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        avatarRadius + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildContent(context),
      ),
    );

    final whiteCard = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(cornerRadius),
        ),
      ),
      child: sheetContent,
    );

    if (expand) {
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ColoredBox(color: _themeColor),
          ),
          Positioned(
            top: sheetInsets.top,
            left: sheetInsets.left,
            right: sheetInsets.right,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(cornerRadius),
              ),
              child: ColoredBox(
                color: AppColors.background,
                child: SingleChildScrollView(
                  child: sheetContent,
                ),
              ),
            ),
          ),
          Positioned(
            top: avatarTop,
            left: 0,
            right: 0,
            child: Center(child: avatar),
          ),
          if (topBar != null)
            Positioned(
              top: topInset + context.rs(toolbarTopOffset),
              left: 0,
              right: 0,
              child: topBar!,
            ),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: sheetInsets,
          child: whiteCard,
        ),
        Positioned(
          top: avatarTop,
          left: 0,
          right: 0,
          child: Center(child: avatar),
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
