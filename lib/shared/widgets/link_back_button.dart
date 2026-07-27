import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class LinkBackButton extends StatelessWidget {
  const LinkBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed ?? () => _pop(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.bleu_primaire,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.chevron_left_rounded, size: 28),
        label: const Text(
          'Retour',
          style: TextStyle(
            fontSize: AppFontSize.md,
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ),
    );
  }

  void _pop(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.pop();
  }
}
