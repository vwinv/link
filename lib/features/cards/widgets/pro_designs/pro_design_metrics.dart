import 'package:flutter/material.dart';
import 'package:linkflutter/core/utils/responsive.dart';

/// Tailles de référence des designs pro - mises à l’échelle via [BuildContext.rs].
abstract final class ProDesignMetrics {
  static const baseHeroAvatarSize = 136.0;
  static const baseProfileAvatarSize = 88.0;
  static const baseHeaderAvatarRadius = 62.0;
  static const baseHeroTitleSize = 28.0;
  static const baseHeroAvatarTextSize = 36.0;

  static double heroAvatarSize(BuildContext context) =>
      context.rs(baseHeroAvatarSize);

  static double profileAvatarSize(BuildContext context) =>
      context.rs(baseProfileAvatarSize);

  static double headerAvatarRadius(BuildContext context) =>
      context.rs(baseHeaderAvatarRadius);

  static double heroTitleSize(BuildContext context) =>
      context.rs(baseHeroTitleSize);

  static double heroAvatarTextSize(BuildContext context) =>
      context.rs(baseHeroAvatarTextSize);

  static double legacyAvatarSize(
    BuildContext context, {
    required bool compact,
  }) =>
      context.rs(compact ? 40 : 56);
}
