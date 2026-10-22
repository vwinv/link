import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

enum SocialButtonType { apple, google }

class LinkSocialButton extends StatelessWidget {
  const LinkSocialButton({
    required this.type,
    required this.label,
    required this.onPressed,
    super.key,
    this.borderRadius = AppRadius.md,
  });

  final SocialButtonType type;
  final String label;
  final VoidCallback onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isApple = type == SocialButtonType.apple;

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple ? AppColors.appleButton : AppColors.background,
          foregroundColor: isApple ? AppColors.onPrimary : AppColors.textPrimary,
          side: BorderSide(
            color: isApple ? AppColors.appleButton : AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        icon: isApple
            ? const Icon(Icons.apple, size: 22)
            : Image.asset(
                AppAssets.google,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.md,
            fontWeight: AppFontWeight.semiBold,
            color: isApple ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
