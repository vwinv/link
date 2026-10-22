import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';

class LinkLogo extends StatelessWidget {
  const LinkLogo({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final logoHeight = height ??
        context.responsive(
          mobile: AppSizes.logoHeight,
          tablet: AppSizes.logoHeight + 4,
        );

    return Image.asset(
      AppAssets.logo,
      height: logoHeight,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
    );
  }
}
