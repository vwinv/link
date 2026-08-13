import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Bandeau noir Premium (même style que le portfolio).
class PremiumUnlockBanner extends StatelessWidget {
  const PremiumUnlockBanner({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final secondary = subtitle ?? l10n.premiumSeeOffers;

    return Semantics(
      button: true,
      label: '$title, $secondary',
      child: Material(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.or,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        secondary,
                        style: TextStyle(
                          color: AppColors.onPrimary.withValues(alpha: 0.72),
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onPrimary.withValues(alpha: 0.72),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
