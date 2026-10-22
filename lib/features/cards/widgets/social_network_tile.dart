import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/models/social_link_draft.dart';

class SocialNetworkTile extends StatelessWidget {
  const SocialNetworkTile({
    required this.draft,
    required this.controller,
    required this.onToggle,
    required this.onValueChanged,
    super.key,
  });

  final SocialLinkDraft draft;
  final TextEditingController controller;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onValueChanged;

  @override
  Widget build(BuildContext context) {
    final platform = draft.platform;
    final isSelected = draft.isSelected;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.standard,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isSelected ? AppColors.bleu_primaire : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => onToggle(!isSelected),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              children: [
                _PlatformIcon(platform: platform),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    platform.labelL10n(context.l10n),
                    style: const TextStyle(
                      fontSize: AppFontSize.md,
                      fontWeight: AppFontWeight.semiBold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _SelectionIndicator(isSelected: isSelected),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: controller,
              keyboardType: platform.keyboardType,
              onChanged: onValueChanged,
              style: const TextStyle(
                fontSize: AppFontSize.md,
                fontWeight: AppFontWeight.medium,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: platform.placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiaire,
                  fontWeight: AppFontWeight.regular,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.bleu_primaire,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatformIcon extends StatelessWidget {
  const _PlatformIcon({required this.platform});

  final CardSocialPlatform platform;

  @override
  Widget build(BuildContext context) {
    final asset = platform.iconAsset;

    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Image.asset(
          asset,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    }

    if (platform == CardSocialPlatform.website) {
      return Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: platform.brandColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(
          Icons.language_rounded,
          color: AppColors.onPrimary,
          size: 20,
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: platform.brandColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        platform.brandLetter,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.bleu_primaire,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.onPrimary,
          size: 18,
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );
  }
}
