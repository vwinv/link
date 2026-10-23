import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';

Future<void> showPortfolioStatsSheet(
  BuildContext context, {
  required int visits,
  int portfolioClicks = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => PortfolioStatsSheet(
      visits: visits,
      portfolioClicks: portfolioClicks,
    ),
  );
}

class PortfolioStatsSheet extends StatelessWidget {
  const PortfolioStatsSheet({
    required this.visits,
    this.portfolioClicks = 0,
    super.key,
  });

  final int visits;
  final int portfolioClicks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dotInactive,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.portfolioStatsTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(20),
                    fontWeight: AppFontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Material(
                color: AppColors.iconBgMuted,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _StatTile(
                  value: visits,
                  label: l10n.portfolioStatsVisits,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  value: portfolioClicks,
                  label: l10n.portfolioStatsClicks,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.portfolioStatsHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiaire,
              fontSize: context.rs(13),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: TextStyle(
                  fontSize: context.rs(16),
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              child: Text(l10n.portfolioStatsClose),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.rs(34),
              fontWeight: AppFontWeight.bold,
              height: 1,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(13),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
