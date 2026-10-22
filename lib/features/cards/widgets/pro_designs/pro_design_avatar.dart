import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

/// Avatar des designs pro - photo, logo d’équipe ou initiales.
class ProDesignAvatar extends StatelessWidget {
  const ProDesignAvatar({
    required this.size,
    required this.initials,
    this.avatarUrl,
    this.logoUrl,
    this.backgroundColor = AppColors.onPrimary,
    this.foregroundColor,
    this.fontSize,
    this.borderRadius,
    super.key,
  });

  final double size;
  final String initials;
  final String? avatarUrl;
  final String? logoUrl;
  final Color backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final BorderRadius? borderRadius;

  String? get _resolvedImageUrl {
    final portrait = avatarUrl?.trim();
    if (portrait != null && portrait.isNotEmpty) return portrait;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    final imageUrl = _resolvedImageUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initialsText(),
            )
          : _initialsText(),
    );
  }

  Widget _initialsText() {
    return Text(
      initials,
      style: TextStyle(
        color: foregroundColor ?? AppColors.textPrimary,
        fontSize: fontSize ?? size * 0.26,
        fontWeight: AppFontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }
}
