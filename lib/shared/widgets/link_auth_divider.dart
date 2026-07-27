import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';

class LinkAuthDivider extends StatelessWidget {
  const LinkAuthDivider({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final label = text ?? context.l10n.commonOrEmail;
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSize.sm,
              color: AppColors.textTertiaire,
              fontWeight: AppFontWeight.medium,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }
}
