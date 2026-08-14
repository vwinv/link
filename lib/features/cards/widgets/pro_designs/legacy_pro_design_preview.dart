import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_avatar.dart';
import 'package:linkflutter/features/cards/widgets/pro_designs/pro_design_metrics.dart';

class LegacyProDesignPreview extends StatelessWidget {
  const LegacyProDesignPreview({
    required this.template,
    required this.fullName,
    required this.initials,
    required this.subtitle,
    required this.companyName,
    this.address,
    this.tagLabel = '',
    this.compact = false,
    this.logoUrl,
    this.avatarUrl,
    super.key,
  });

  final ProDesignTemplate template;
  final String fullName;
  final String initials;
  final String subtitle;
  final String companyName;
  final String? address;
  final String tagLabel;
  final bool compact;
  final String? avatarUrl;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final avatarSize =
        ProDesignMetrics.legacyAvatarSize(context, compact: compact);
    final nameSize = compact ? 12.0 : 16.0;
    final subtitleSize = compact ? 9.0 : 11.0;
    final headerIconSize = compact ? 11.0 : 14.0;
    final actionFontSize = compact ? 8.0 : 10.0;
    final actionPadding = compact ? 5.0 : 8.0;
    final accent = template.accentColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: template.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: template.background.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.or,
                size: headerIconSize,
              ),
              const SizedBox(width: 4),
              if (logoUrl != null && logoUrl!.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    logoUrl!,
                    width: compact ? 14 : 18,
                    height: compact ? 14 : 18,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  companyName,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: compact ? 9 : 11,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.menu_rounded,
                color: AppColors.onPrimary,
                size: compact ? 14 : 16,
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ProDesignAvatar(
              size: avatarSize,
              initials: initials,
              avatarUrl: avatarUrl,
              logoUrl: logoUrl,
              fontSize: compact ? 13 : 18,
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            fullName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: nameSize,
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle.isNotEmpty ? subtitle : tagLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.onPrimary.withValues(alpha: 0.8),
              fontSize: subtitleSize,
              height: 1.3,
            ),
          ),
          if ((address ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              address!.trim(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.onPrimary.withValues(alpha: 0.7),
                fontSize: subtitleSize,
                height: 1.3,
              ),
            ),
          ],
          const Spacer(),
          _PreviewActionButton(
            label: 'Échanger mes coordonnées',
            color: accent,
            fontSize: actionFontSize,
            verticalPadding: actionPadding,
          ),
          SizedBox(height: compact ? 4 : AppSpacing.sm),
          _PreviewActionButton(
            label: 'Enregistrer le contact',
            color: accent,
            fontSize: actionFontSize,
            verticalPadding: actionPadding,
          ),
          SizedBox(height: compact ? 4 : AppSpacing.sm),
          _PreviewActionButton(
            label: 'M’appeler',
            color: accent,
            fontSize: actionFontSize,
            verticalPadding: actionPadding,
          ),
          SizedBox(height: compact ? 4 : AppSpacing.sm),
          _PreviewActionButton(
            label: 'M’envoyer un message',
            color: accent,
            fontSize: actionFontSize,
            verticalPadding: actionPadding,
          ),
          SizedBox(height: compact ? 4 : AppSpacing.sm),
          _PreviewActionButton(
            label: 'M’écrire par email',
            color: accent,
            fontSize: actionFontSize,
            verticalPadding: actionPadding,
          ),
        ],
      ),
    );
  }
}

class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
    required this.label,
    required this.color,
    this.fontSize = 10,
    this.verticalPadding = 8,
  });

  final String label;
  final Color color;
  final double fontSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}
