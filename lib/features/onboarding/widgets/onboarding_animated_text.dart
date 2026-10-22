import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/utils/responsive.dart';

class OnboardingAnimatedText extends StatelessWidget {
  const OnboardingAnimatedText({
    required this.title,
    required this.description,
    required this.pageKey,
    super.key,
  });

  final String title;
  final String description;
  final int pageKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.textTransition,
      switchInCurve: AppCurves.enter,
      switchOutCurve: AppCurves.exit,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(pageKey),
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: context.rs(
                    context.responsive(
                      mobile: AppFontSize.xl,
                      tablet: AppFontSize.xxl,
                    ),
                  ),
                  fontWeight: AppFontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: context.rs(
                    context.responsive(
                      mobile: AppFontSize.md,
                      tablet: AppFontSize.lg,
                    ),
                  ),
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
