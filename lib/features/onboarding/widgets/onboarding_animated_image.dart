import 'package:flutter/material.dart';
import 'package:linkflutter/core/utils/responsive.dart';

class OnboardingAnimatedImage extends StatelessWidget {
  const OnboardingAnimatedImage({
    required this.imagePath,
    required this.pageController,
    required this.index,
    super.key,
  });

  final String imagePath;
  final PageController pageController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final page = pageController.hasClients
            ? (pageController.page ?? pageController.initialPage.toDouble())
            : pageController.initialPage.toDouble();

        final delta = page - index;
        final progress = (1 - delta.abs()).clamp(0.0, 1.0);

        final slideOffset = context.responsive(mobile: 48.0, tablet: 56.0);

        return Transform.translate(
          offset: Offset(delta * slideOffset, delta.abs() * 12),
          child: Transform.scale(
            scale: 0.88 + (0.12 * progress),
            child: Opacity(
              opacity: 0.35 + (0.65 * progress),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        imagePath,
        height: Responsive.onboardingImageHeight(context),
        fit: BoxFit.contain,
      ),
    );
  }
}
