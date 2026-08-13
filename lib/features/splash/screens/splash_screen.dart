import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_assets.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/onboarding_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    try {
      await _boot().timeout(const Duration(seconds: 18));
    } catch (_) {
      // Ne jamais rester bloqué sur le splash (simulateur iOS, API down, etc.).
    }
    if (!mounted) return;
    _goNext();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final accountType = context.read<AccountTypeProvider>();

    await Future.wait([
      auth.checkAuthStatus(),
      onboarding.load(),
      accountType.load(),
      context.read<WorkspaceModeProvider>().load(),
    ]);

    if (!mounted) return;

    await context.read<DeepLinkService>().ensureReady().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
    if (!mounted) return;

    if (auth.isAuthenticated) {
      await bootstrapUserWorkspace(context);
    }
  }

  void _goNext() {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final accountType = context.read<AccountTypeProvider>();
    final pendingSlug = context.read<DeepLinkService>().consumePendingSlug();

    if (pendingSlug != null) {
      context.go('${RoutePaths.publicCard}/$pendingSlug');
      return;
    }
    if (auth.isAuthenticated) {
      context.go(RoutePaths.home);
    } else if (!onboarding.hasCompletedOnboarding) {
      context.go(RoutePaths.onboarding);
    } else if (!accountType.hasCompletedAccountType) {
      context.go(RoutePaths.accountType);
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.icone,
              width: AppSizes.splashIconSize,
              height: AppSizes.splashIconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
