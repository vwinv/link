import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

enum ScreenType { mobile, tablet, desktop }

abstract final class Responsive {
  static ScreenType screenTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.tablet) return ScreenType.desktop;
    if (width >= AppBreakpoints.mobile) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (screenTypeOf(context)) {
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.mobile => mobile,
    };
  }

  static double scale(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
    final factor = width / AppBreakpoints.designWidth;
    return size * factor.clamp(0.85, 1.25);
  }

  static double contentMaxWidth(BuildContext context) {
    return value(
      context,
      mobile: double.infinity,
      tablet: AppBreakpoints.contentWidthTablet,
      desktop: AppBreakpoints.contentWidthDesktop,
    );
  }

  static EdgeInsets screenPadding(BuildContext context) {
    final horizontal = value(
      context,
      mobile: AppSpacing.screenHorizontal,
      tablet: AppSpacing.xxl,
      desktop: AppSpacing.xl,
    );

    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  static double buttonHeight(BuildContext context) {
    return value(
      context,
      mobile: AppSizes.buttonHeight,
      tablet: 60,
      desktop: 56,
    );
  }

  static double onboardingImageHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final base = value(
      context,
      mobile: AppSizes.onboardingImageHeight,
      tablet: 320.0,
      desktop: 340.0,
    );

    if (height < 650) return base * 0.75;
    if (height < 750) return base * 0.9;
    return base.toDouble();
  }
}

extension ResponsiveContext on BuildContext {
  ScreenType get screenType => Responsive.screenTypeOf(this);

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  EdgeInsets get screenPadding => Responsive.screenPadding(this);
  double get contentMaxWidth => Responsive.contentMaxWidth(this);

  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    return Responsive.value(this, mobile: mobile, tablet: tablet, desktop: desktop);
  }

  double rs(double size) => Responsive.scale(this, size);
}
