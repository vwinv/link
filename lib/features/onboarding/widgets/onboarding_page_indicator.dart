import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    required this.count,
    required this.pageController,
    super.key,
  });

  final int count;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = pageController.hasClients
            ? (pageController.page ?? pageController.initialPage.toDouble())
            : pageController.initialPage.toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final distance = (page - index).abs().clamp(0.0, 1.0);
            final activation = 1 - distance;

            return AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width:
                  AppSizes.dotWidthInactive +
                  ((AppSizes.dotWidthActive - AppSizes.dotWidthInactive) *
                      activation),
              height: AppSizes.dotHeight,
              decoration: BoxDecoration(
                color: Color.lerp(
                  AppColors.dotInactive,
                  AppColors.bleu_primaire,
                  activation,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
            );
          }),
        );
      },
    );
  }
}
