import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Attribution MEGA en bas des écrans pré-accueil.
class CreatedByMega extends StatelessWidget {
  const CreatedByMega({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.createdByMega,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.bleu_primaire,
        fontSize: context.rs(AppFontSize.sm),
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.3,
      ),
    );
  }
}
