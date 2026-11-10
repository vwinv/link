import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Attribution MEGA, toujours centrée tout en bas des écrans pré-accueil.
class CreatedByMega extends StatelessWidget {
  const CreatedByMega({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Center(
        child: Text(
          context.l10n.createdByMega,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textTertiaire.withValues(alpha: 0.55),
            fontSize: context.rs(11),
            fontWeight: AppFontWeight.medium,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
