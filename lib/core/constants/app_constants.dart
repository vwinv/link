import 'package:flutter/material.dart';

// ─── App ─────────────────────────────────────────────────────────────────────

abstract final class AppConstants {
  static const appName = 'DropOne';
  static const apiBaseUrl = 'http://localhost:3000/api/v1';
}

// ─── Couleurs ────────────────────────────────────────────────────────────────

abstract final class AppColors {
  static const bleu_primaire = Color(0xFF0A6BFF);
  static const bleu_fonce = Color(0xFF0A53C7);
  static const bleu_clair = Color(0xFFE8F0FF);
  static const bleu_turquoise_clair = Color(0xFFDCF3F8);
  static const bleu_turquoise = Color(0xFF0FA3C1);
  static const onPrimary = Color(0xFFFFFFFF);
  static const vert_clair = Color(0xFFE7F6EC);
  static const rouge_clair = Color(0xFFFDECEC);

  static const or = Color(0xFFFFC400);
  static const or_fonce = Color(0xFF1A1503);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF0C0D10);
  static const textSecondary = Color(0xFF5B616E);
  static const textTertiaire = Color(0xFF9AA0AC);

  static const dotInactive = Color(0xFFD1D1D6);

  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFEF4444);
  static const onError = Color(0xFFFFFFFF);

  static const border = Color(0xFFE5E5EA);
  static const divider = Color(0xFFE5E5EA);

  static const iconBgMuted = Color(0xFFF2F2F7);
  static const iconBgMutedDark = Color(0xFFE5E5EA);
  static const inputFill = Color(0xFFF2F2F7);
  static const appleButton = Color(0xFF000000);
}

// ─── Espacements ─────────────────────────────────────────────────────────────

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  static const screenHorizontal = 24.0;
}

// ─── Rayons de bordure ───────────────────────────────────────────────────────

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 28.0;
  static const full = 999.0;
}

// ─── Tailles ─────────────────────────────────────────────────────────────────

abstract final class AppSizes {
  static const logoHeight = 32.0;
  static const headerLogoHeight = 52.0;
  static const splashIconSize = 72.0;
  static const buttonHeight = 58.0;
  static const inputHeight = 48.0;
  static const onboardingImageHeight = 280.0;
  static const dotHeight = 8.0;
  static const dotWidthInactive = 8.0;
  static const dotWidthActive = 28.0;
  static const accountTypeCardMinHeight = 120.0;
}

// ─── Typographie ─────────────────────────────────────────────────────────────

abstract final class AppFontSize {
  static const sm = 14.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 28.0;
}

abstract final class AppFontWeight {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w800;
}

// ─── Animations ──────────────────────────────────────────────────────────────

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 250);
  static const pageTransition = Duration(milliseconds: 480);
  static const textTransition = Duration(milliseconds: 420);
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
}

// ─── Breakpoints ─────────────────────────────────────────────────────────────

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const designWidth = 375.0;

  static const contentWidthTablet = 560.0;
  static const contentWidthDesktop = 480.0;
}
