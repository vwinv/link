import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';

class CreateCardPortfolioSection extends StatelessWidget {
  const CreateCardPortfolioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l10n.premiumFeaturePortfolio,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: context.rs(AppFontSize.xl),
                    fontWeight: AppFontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            const _PremiumBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.premiumPortfolioSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _PortfolioPremiumBanner(onTap: () => openLinkPremium(context)),
      ],
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.or_fonce,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.or),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.l10n.premiumBadge,
            style: const TextStyle(
              color: AppColors.or,
              fontSize: AppFontSize.sm,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioPremiumBanner extends StatelessWidget {
  const _PortfolioPremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: '${l10n.premiumPortfolioLinked}, ${l10n.premiumSeeOffers}',
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
                        l10n.premiumPortfolioLinked,
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.premiumSeeOffers,
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
