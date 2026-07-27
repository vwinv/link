import 'package:linkflutter/core/bootstrap/workspace_local_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:provider/provider.dart';

bool hasExistingWorkspace(CardsProvider cards, TeamsProvider teams) {
  return cards.hasPersonalCard ||
      cards.hasProfessionalCard ||
      cards.hasCards ||
      teams.hasTeam;
}

void resetUserWorkspaceState({
  required CardsProvider cards,
  required TeamsProvider teams,
  required ContactsProvider contacts,
  CreateCardProvider? createCard,
  WorkspaceModeProvider? workspace,
}) {
  cards.reset();
  teams.reset();
  contacts.reset();
  createCard?.reset();
  workspace?.reset();
}

/// Réinitialise l'espace utilisateur en mémoire (évite les données du compte précédent).
void resetUserWorkspace(BuildContext context) {
  resetUserWorkspaceState(
    cards: context.read<CardsProvider>(),
    teams: context.read<TeamsProvider>(),
    contacts: context.read<ContactsProvider>(),
    createCard: context.read<CreateCardProvider>(),
    workspace: context.read<WorkspaceModeProvider>(),
  );
  context.read<SubscriptionsProvider>().clear();
}

/// Charge l'espace utilisateur sans réinitialiser l'état en mémoire.
/// Utile après un deep link (scan QR) quand le splash saute le bootstrap complet.
Future<void> ensureUserWorkspaceLoaded(BuildContext context) async {
  final cards = context.read<CardsProvider>();
  final teams = context.read<TeamsProvider>();
  final contacts = context.read<ContactsProvider>();

  await Future.wait([
    if (!cards.hasLoaded) cards.load(),
    if (!teams.hasLoaded) teams.load(),
    if (!contacts.hasLoaded) contacts.load(),
  ]);
}

/// Charge cartes + équipe et crée la carte pro si besoin.
Future<void> bootstrapUserWorkspace(BuildContext context) async {
  resetUserWorkspace(context);

  final cards = context.read<CardsProvider>();
  final teams = context.read<TeamsProvider>();
  final workspace = context.read<WorkspaceModeProvider>();
  final user = context.read<AuthProvider>().user;
  teams.setCurrentUserId(user?.id);

  if (!workspace.isLoaded) {
    await workspace.load();
  }

  if (user != null) {
    await WorkspaceLocalCache.hydrate(
      userId: user.id,
      cards: cards,
      teams: teams,
    );
  }

  await Future.wait([
    cards.load(),
    teams.load(),
    context.read<ContactsProvider>().load(),
  ]);

  final team = teams.ownedTeam;
  if (team != null && !cards.hasProfessionalCard && user != null) {
    try {
      await cards.ensureProfessionalCardForTeam(team, owner: user);
    } catch (_) {
      // L'équipe suffit pour considérer l'espace comme configuré.
    }
  }

  // Si le mode membre est actif mais plus d’accès → revenir au perso.
  if (workspace.isMember && !teams.canAccessMemberSpace) {
    await workspace.switchToPersonal();
  }

  if (user != null) {
    await WorkspaceLocalCache.persist(
      userId: user.id,
      cards: cards,
      teams: teams,
    );
  }
}

Future<void> persistUserWorkspace(BuildContext context) async {
  final user = context.read<AuthProvider>().user;
  if (user == null) return;
  await WorkspaceLocalCache.persist(
    userId: user.id,
    cards: context.read<CardsProvider>(),
    teams: context.read<TeamsProvider>(),
  );
}
