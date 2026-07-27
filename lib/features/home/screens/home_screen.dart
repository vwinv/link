import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.child, super.key});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.scan)) return 1;
    if (location.startsWith(RoutePaths.contacts)) return 2;
    if (location.startsWith(RoutePaths.profile)) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.home);
      case 1:
        context.go(RoutePaths.scan);
      case 2:
        context.go(RoutePaths.contacts);
      case 3:
        context.go(RoutePaths.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardsProvider>();
    final teams = context.watch<TeamsProvider>();
    final workspaceReady = cards.hasLoaded && teams.hasLoaded;
    final showNavigation =
        workspaceReady && hasExistingWorkspace(cards, teams);

    return Scaffold(
      body: child,
      bottomNavigationBar: showNavigation
          ? NavigationBar(
              selectedIndex: _selectedIndex(context),
              onDestinationSelected: (index) => _onItemTapped(context, index),
              indicatorColor: AppColors.bleu_clair,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.credit_card_outlined),
                  selectedIcon: const Icon(Icons.credit_card),
                  label: context.l10n.navCards,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.document_scanner_outlined),
                  selectedIcon: const Icon(Icons.document_scanner),
                  label: context.l10n.navScan,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: context.l10n.navContacts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: context.l10n.navProfile,
                ),
              ],
            )
          : null,
    );
  }
}
