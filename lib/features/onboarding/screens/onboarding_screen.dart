import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/shared/widgets/created_by_mega.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:linkflutter/features/onboarding/models/onboarding_item.dart';
import 'package:linkflutter/features/onboarding/widgets/onboarding_animated_image.dart';
import 'package:linkflutter/features/onboarding/widgets/onboarding_animated_text.dart';
import 'package:linkflutter/features/onboarding/widgets/onboarding_header.dart';
import 'package:linkflutter/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:linkflutter/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingItem> _pages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingItem(
        imagePath: AppAssets.onboardingCard,
        title: l10n.onboardingPage1Title,
        description: l10n.onboardingPage1Description,
        buttonLabel: l10n.commonContinue,
      ),
      OnboardingItem(
        imagePath: AppAssets.onboardingAirdrop,
        title: l10n.onboardingPage2Title,
        description: l10n.onboardingPage2Description,
        buttonLabel: l10n.commonContinue,
      ),
      OnboardingItem(
        imagePath: AppAssets.onboardingWallet,
        title: l10n.onboardingPage3Title,
        description: l10n.onboardingPage3Description,
        buttonLabel: l10n.commonStart,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<OnboardingProvider>().complete();
    if (!mounted) return;
    context.go(RoutePaths.accountType);
  }

  void _onNext() {
    final pages = _pages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.pageTransition,
        curve: AppCurves.standard,
      );
      return;
    }
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages(context);
    final page = pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              OnboardingHeader(onSkip: _finish),
              Expanded(
                flex: context.responsive(mobile: 5, tablet: 6, desktop: 5),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Center(
                      child: OnboardingAnimatedImage(
                        imagePath: pages[index].imagePath,
                        pageController: _pageController,
                        index: index,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: context.screenPadding,
                child: OnboardingAnimatedText(
                  pageKey: _currentPage,
                  title: page.title,
                  description: page.description,
                ),
              ),
              SizedBox(
                height: context.responsive(
                  mobile: AppSpacing.xxl,
                  tablet: AppSpacing.xxxl,
                ),
              ),
              OnboardingPageIndicator(
                count: pages.length,
                pageController: _pageController,
              ),
              SizedBox(
                height: context.responsive(
                  mobile: AppSpacing.xl,
                  tablet: AppSpacing.xxl,
                ),
              ),
              Padding(
                padding: context.screenPadding.copyWith(bottom: AppSpacing.sm),
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.buttonHeight(context),
                  child: AnimatedSwitcher(
                    duration: AppDurations.normal,
                    child: FilledButton(
                      key: ValueKey(page.buttonLabel),
                      onPressed: _onNext,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.bleu_primaire,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: Text(
                        page.buttonLabel,
                        style: TextStyle(
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const CreatedByMega(),
            ],
          ),
        ),
      ),
    );
  }
}
