import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/features/splash/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/features/auth/screens/account_type_screen.dart';
import 'package:linkflutter/features/auth/screens/login_screen.dart';
import 'package:linkflutter/features/auth/screens/register_screen.dart';
import 'package:linkflutter/features/contacts/screens/contacts_screen.dart';
import 'package:linkflutter/features/cards/screens/my_cards_screen.dart';
import 'package:linkflutter/features/cards/screens/create_card_prompt_screen.dart';
import 'package:linkflutter/features/cards/screens/create_card_step1_screen.dart';
import 'package:linkflutter/features/cards/screens/create_card_step2_screen.dart';
import 'package:linkflutter/features/cards/models/card_ready_data.dart';
import 'package:linkflutter/features/cards/screens/create_card_step3_screen.dart';
import 'package:linkflutter/features/cards/screens/create_card_success_screen.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/features/home/screens/home_screen.dart';
import 'package:linkflutter/features/profile/screens/profile_screen.dart';
import 'package:linkflutter/features/notifications/screens/notifications_screen.dart';
import 'package:linkflutter/features/onboarding/screens/onboarding_screen.dart';
import 'package:linkflutter/features/scan/screens/scan_screen.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/subscriptions/screens/link_premium_screen.dart';
import 'package:linkflutter/features/teams/screens/setup_team_screen.dart';
import 'package:linkflutter/features/teams/screens/member_home_screen.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:linkflutter/core/deep_link/deep_link_parser.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/features/sharing/screens/public_card_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter create(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final cardsProvider = context.read<CardsProvider>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.splash,
      refreshListenable: Listenable.merge([
        authProvider,
        cardsProvider,
      ]),
      redirect: (context, state) {
        final publicSlug = parseCardSlugFromUri(state.uri);
        if (publicSlug != null) {
          final deepLinks = context.read<DeepLinkService>();
          if (deepLinks.isPublicCardDismissed(publicSlug)) {
            return RoutePaths.home;
          }
          final target = '${RoutePaths.publicCard}/$publicSlug';
          if (state.matchedLocation != target) {
            return target;
          }
        }

        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute =
            state.matchedLocation == RoutePaths.login ||
            state.matchedLocation == RoutePaths.register;
        final isSplash = state.matchedLocation == RoutePaths.splash;
        final isOnboarding = state.matchedLocation == RoutePaths.onboarding;
        final isAccountType = state.matchedLocation == RoutePaths.accountType;
        final isCreateCardEntry =
            state.matchedLocation == RoutePaths.createCard;

        if (authProvider.isLoading) return null;

        final isPublicCard = state.matchedLocation.startsWith(
          '${RoutePaths.publicCard}/',
        );

        if (isSplash || isOnboarding || isAccountType || isPublicCard) {
          return null;
        }

        if (!isAuthenticated && !isAuthRoute) {
          return RoutePaths.login;
        }

        if (isAuthenticated && isAuthRoute) {
          return RoutePaths.home;
        }

        if (isAuthenticated &&
            isCreateCardEntry &&
            cardsProvider.hasPersonalCard &&
            context.read<CreateCardProvider>().card == null) {
          return RoutePaths.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.accountType,
          builder: (context, state) => const AccountTypeScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RoutePaths.createCard,
          builder: (context, state) => const CreateCardStep1Screen(),
          routes: [
            GoRoute(
              path: 'step-2',
              builder: (context, state) => const CreateCardStep2Screen(),
            ),
            GoRoute(
              path: 'step-3',
              builder: (context, state) => const CreateCardStep3Screen(),
            ),
            GoRoute(
              path: 'success',
              builder: (context, state) {
                final data = state.extra;
                if (data is! CardReadyData) {
                  return const CreateCardStep1Screen();
                }
                return CreateCardSuccessScreen(data: data);
              },
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '${RoutePaths.publicCard}/:slug',
          pageBuilder: (context, state) {
            final slug = state.pathParameters['slug'] ?? '';
            return MaterialPage<void>(
              key: state.pageKey,
              fullscreenDialog: true,
              child: PublicCardScreen(slug: slug),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.premium,
          pageBuilder: (context, state) {
            final preferredAudience = state.extra is OfferAudience
                ? state.extra! as OfferAudience
                : null;
            return MaterialPage<void>(
              key: state.pageKey,
              fullscreenDialog: true,
              child: LinkPremiumScreen(preferredAudience: preferredAudience),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.createProfessionalTeam,
          builder: (context, state) => const SetupTeamScreen(),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: RoutePaths.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.home,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: _HomeTab()),
            ),
            GoRoute(
              path: RoutePaths.cards,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: MyCardsScreen()),
            ),
            GoRoute(
              path: RoutePaths.scan,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScanScreen()),
            ),
            GoRoute(
              path: RoutePaths.contacts,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ContactsScreen()),
            ),
            GoRoute(
              path: RoutePaths.profile,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsProvider>();
    final teams = context.watch<TeamsProvider>();
    final workspace = context.watch<WorkspaceModeProvider>();

    if ((!cards.hasLoaded || !teams.hasLoaded) &&
        !hasExistingWorkspace(cards, teams)) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (workspace.isMember && teams.canAccessMemberSpace) {
      return const MemberHomeScreen();
    }

    if (!hasExistingWorkspace(cards, teams)) {
      return const CreateCardPromptScreen();
    }

    return const MyCardsScreen();
  }
}
