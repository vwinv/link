import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class LinkPrimaryButton extends StatelessWidget {
  const LinkPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.borderRadius = AppRadius.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed == null
            ? null
            : const [
                BoxShadow(
                  color: Color(0x4D0A6BFF),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
      ),
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.bleu_primaire,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.bleu_primaire.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
      ),
    );
  }
}
