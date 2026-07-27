import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/shared/widgets/link_logo.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.screenPadding.copyWith(
        top: AppSpacing.sm,
        right: AppSpacing.lg,
        bottom: 0,
      ),
      child: Row(
        children: [
          const LinkLogo(),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            child: Text(
              context.l10n.commonSkip,
              style: const TextStyle(
                color: AppColors.textTertiaire,
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
