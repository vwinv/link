import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/features/sharing/screens/share_card_screen.dart';
import 'package:linkflutter/features/sharing/screens/share_portfolio_screen.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/sharing/models/share_quota.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/pro_design_template.dart';
import 'package:linkflutter/features/cards/screens/customize_card_screen.dart';
import 'package:linkflutter/features/cards/screens/edit_card_info_screen.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/auth/models/account_type.dart';
import 'package:linkflutter/features/cards/screens/my_card_screen.dart';
import 'package:linkflutter/features/cards/models/card_visitors.dart';
import 'package:linkflutter/features/cards/screens/card_analytics_screen.dart';
import 'package:linkflutter/features/cards/screens/card_visitor_detail_screen.dart';
import 'package:linkflutter/features/cards/screens/card_visitors_screen.dart';
import 'package:linkflutter/features/cards/screens/pro_design_preview_screen.dart';
import 'package:linkflutter/features/cards/screens/portfolio_editor_screen.dart';
import 'package:linkflutter/features/cards/screens/portfolio_style_screen.dart';
import 'package:linkflutter/features/cards/screens/professional_designs_screen.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';
import 'package:linkflutter/features/contacts/screens/contact_detail_screen.dart';
import 'package:linkflutter/features/legal/screens/privacy_policy_screen.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/shared/widgets/dark_modal_scope.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/models/team_invitation.dart';
import 'package:linkflutter/features/teams/screens/team_invite_screen.dart';
import 'package:linkflutter/features/teams/screens/team_members_screen.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/features/wallet/screens/add_to_wallet_screen.dart';
import 'package:linkflutter/features/wallet/services/wallet_platform_service.dart';
import 'package:provider/provider.dart';

/// Après connexion ou inscription : charge l'espace utilisateur puis enchaîne
/// sur la configuration équipe si le parcours « équipe » ou l'abonnement le requiert.
Future<void> completePostAuthNavigation(
  BuildContext context, {
  String? returnTo,
}) async {
  await bootstrapUserWorkspace(context);
  if (!context.mounted) return;

  final subscriptions = context.read<SubscriptionsProvider>();
  await subscriptions.refresh();
  if (!context.mounted) return;

  final redirect = returnTo?.trim();
  if (redirect != null && redirect.isNotEmpty) {
    context.go(redirect);
    return;
  }

  final workspace = context.read<WorkspaceModeProvider>();
  final wantsMemberLogin = await workspace.consumeMemberLoginIntent();
  if (!context.mounted) return;

  if (wantsMemberLogin) {
    await enterMemberWorkspace(context);
    return;
  }

  if (!context.mounted) return;
  final intent = await context
      .read<AccountTypeProvider>()
      .consumeAuthFlowIntent();
  if (!context.mounted) return;
  final teams = context.read<TeamsProvider>();
  final cards = context.read<CardsProvider>();

  final wantsTeamOnboarding = intent == AccountType.team;
  final hasTeamSubscription = subscriptions.hasTeamSubscription;
  final needsTeamWorkspace = !teams.hasTeam || !cards.hasProfessionalCard;

  // En review Apple (HIDE_IN_APP_PAYMENTS), hasTeamSubscription est forcé
  // à true pour débloquer les features — ne pas en déduire le parcours équipe.
  final shouldContinueTeamSetup = wantsTeamOnboarding ||
      (!subscriptions.isAppleReviewFullAccess &&
          hasTeamSubscription &&
          needsTeamWorkspace);

  if (shouldContinueTeamSetup) {
    await openSetupProfessionalTeam(context);
    if (!context.mounted) return;
    await persistUserWorkspace(context);
  }

  if (!context.mounted) return;
  await workspace.switchToPersonal();
  if (!context.mounted) return;
  context.go(RoutePaths.home);
}

/// Passe à l’espace perso (cartes personnelles / pro owner).
Future<void> switchToPersonalWorkspace(BuildContext context) async {
  await context.read<WorkspaceModeProvider>().switchToPersonal();
  if (!context.mounted) return;
  context.go(RoutePaths.home);
}

/// Ouvre l’espace membre : invitation en attente, accès membre, ou refus bloqué.
Future<void> enterMemberWorkspace(BuildContext context) async {
  final teamsApi = context.read<TeamsApiService>();
  final teams = context.read<TeamsProvider>();
  final workspace = context.read<WorkspaceModeProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;

  List<TeamInvitation>? invitations;
  try {
    invitations = await teamsApi.fetchMyInvitations();
  } catch (_) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.teamInvitationRespondError)),
    );
    return;
  }

  if (!context.mounted) return;

  if (invitations.isNotEmpty) {
    await openTeamInviteScreen(context, invitations.first);
    return;
  }

  await teams.load();
  if (!context.mounted) return;

  if (teams.canAccessMemberSpace) {
    final user = context.read<AuthProvider>().user;
    final cards = context.read<CardsProvider>();
    final team = teams.memberTeam;
    if (team != null && user != null) {
      try {
        await cards.ensureMemberCardForTeam(team, owner: user);
      } catch (_) {
        await cards.load(force: true);
      }
    }
    await workspace.switchToMember();
    if (!context.mounted) return;
    context.go(RoutePaths.home);
    return;
  }

  await workspace.switchToPersonal();
  if (!context.mounted) return;
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.workspaceMemberAccessBlocked)),
  );
  context.go(RoutePaths.home);
}

/// Affiche l’écran d’acceptation / refus d’invitation équipe.
Future<void> openTeamInviteScreen(
  BuildContext context,
  TeamInvitation invitation,
) {
  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => MultiProvider(
            providers: [
              Provider<TeamsApiService>.value(
                value: context.read<TeamsApiService>(),
              ),
              ChangeNotifierProvider<TeamsProvider>.value(
                value: context.read<TeamsProvider>(),
              ),
              ChangeNotifierProvider<CardsProvider>.value(
                value: context.read<CardsProvider>(),
              ),
              ChangeNotifierProvider<AuthProvider>.value(
                value: context.read<AuthProvider>(),
              ),
              ChangeNotifierProvider<WorkspaceModeProvider>.value(
                value: context.read<WorkspaceModeProvider>(),
              ),
            ],
            child: TeamInviteScreen(invitation: invitation),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l'écran Premium au-dessus du parcours en cours.
Future<void> openLinkPremium(
  BuildContext context, {
  OfferAudience? preferredAudience,
}) async {
  final subscriptions = context.read<SubscriptionsProvider>();
  await subscriptions.ensurePaymentConfigLoaded();
  if (!context.mounted) return;
  final portfolioOffers = preferredAudience == OfferAudience.portfolio;
  if (subscriptions.hidePremiumUpsells && !portfolioOffers) return;

  await GoRouter.of(
    context,
  ).push<void>(RoutePaths.premium, extra: preferredAudience);
}

/// Ouvre les offres Premium en pré-sélectionnant l’offre équipe.
Future<void> openLinkPremiumForTeam(BuildContext context) {
  return openLinkPremium(context, preferredAudience: OfferAudience.team);
}

/// Vérifie qu’un abonnement équipe est actif ; propose Premium équipe sinon.
Future<bool> ensureTeamSubscription(BuildContext context) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return false;

  if (subscriptionsProvider.isAppleReviewFullAccess ||
      subscriptionsProvider.hasTeamSubscription) {
    return true;
  }

  await openLinkPremiumForTeam(context);
  if (!context.mounted) return false;

  await subscriptionsProvider.refresh();
  if (!context.mounted) return false;

  return subscriptionsProvider.hasTeamSubscription;
}

/// Carte pro / membre : exige une offre équipe valide.
Future<bool> ensureCardOfferAccess(
  BuildContext context,
  BusinessCard card,
) async {
  if (!card.kind.isTeamLinked) return true;

  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return false;

  final team = _teamForCard(context, card);
  if (subscriptionsProvider.canUseTeamLinkedCard(card, team: team)) {
    return true;
  }

  await openLinkPremium(
    context,
    preferredAudience: OfferAudience.team,
  );
  return false;
}

/// Ouvre la configuration équipe (préremplie si une équipe existe déjà).
Future<Team?> openSetupTeam(BuildContext context) async {
  final teamsProvider = context.read<TeamsProvider>();

  if (!teamsProvider.hasLoaded) {
    await teamsProvider.load();
  }
  if (!context.mounted) return null;

  return GoRouter.of(context).push<Team>(RoutePaths.createProfessionalTeam);
}

/// Étape 2 : gestion des membres de l’équipe.
Future<bool> openTeamMembers(
  BuildContext context, {
  required Team team,
  bool showBackButton = true,
}) async {
  final teamsApi = context.read<TeamsApiService>();
  final subscriptionsProvider = context.read<SubscriptionsProvider>();

  final result =
      await rootNavigatorKey.currentState?.push<bool>(
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              Provider<TeamsApiService>.value(value: teamsApi),
              ChangeNotifierProvider<SubscriptionsProvider>.value(
                value: subscriptionsProvider,
              ),
            ],
            child: TeamMembersScreen(
              team: team,
              showBackButton: showBackButton,
            ),
          ),
        ),
      ) ??
      false;

  return result;
}

/// Crée ou met à jour l’équipe puis la carte professionnelle liée.
Future<BusinessCard?> openSetupProfessionalTeam(BuildContext context) async {
  if (!await ensureTeamSubscription(context)) {
    return null;
  }

  final teamsProvider = context.read<TeamsProvider>();
  if (!teamsProvider.hasLoaded) {
    await teamsProvider.load();
  }

  Team? team = teamsProvider.myTeam;

  if (team == null) {
    team = await openSetupTeam(context);
    if (team == null || !context.mounted) return null;
  }

  BusinessCard? card;
  try {
    card = await context.read<CardsProvider>().ensureProfessionalCardForTeam(
      team,
      owner: context.read<AuthProvider>().user,
    );
    if (context.mounted) {
      await persistUserWorkspace(context);
    }
  } on ApiException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
    return null;
  }

  if (!context.mounted) return card;
  await openTeamMembers(context, team: team);
  return card;
}

/// Ouvre l'écran des designs professionnels.
void openProfessionalDesigns(
  BuildContext context, {
  required BusinessCard card,
}) {
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute<void>(
      builder: (_) => ProfessionalDesignsScreen(card: card),
    ),
  );
}

/// Ouvre l'aperçu plein écran d'un modèle pro.
Future<void> openProDesignPreview(
  BuildContext context, {
  required BusinessCard card,
  required ProDesignTemplate template,
  bool useCompanyColors = false,
  String? companyColorHex,
}) {
  final cardsApi = context.read<CardsApiService>();
  final cardsProvider = context.read<CardsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              ChangeNotifierProvider<CardsProvider>.value(value: cardsProvider),
            ],
            child: ProDesignPreviewScreen(
              card: card,
              template: template,
              useCompanyColors: useCompanyColors,
              companyColorHex: companyColorHex,
            ),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Vérifie qu’une capacité offre est active ; ouvre Premium sinon.
Future<bool> ensureOfferCapability(
  BuildContext context, {
  required bool allowed,
  OfferAudience? preferredAudience,
}) async {
  if (allowed) return true;
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  if (subscriptionsProvider.isAppleReviewFullAccess) return true;
  await openLinkPremium(context, preferredAudience: preferredAudience);
  return false;
}

/// Designs pro pour cette carte : perso → offre perso ; pro/membre → offre équipe.
Future<bool> ensureCanCustomizeCard(
  BuildContext context,
  BusinessCard card,
) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return false;

  final team = _teamForCard(context, card);
  return ensureOfferCapability(
    context,
    allowed: subscriptionsProvider.canCustomizeCard(card, team: team),
    preferredAudience: _audienceForCard(card),
  );
}

Team? _teamForCard(BuildContext context, BusinessCard card) {
  return context.read<TeamsProvider>().teamById(card.teamId);
}

OfferAudience _audienceForCard(BusinessCard card) {
  return card.kind.isTeamLinked ? OfferAudience.team : OfferAudience.personal;
}

/// Droits de l’offre Portfolio active (partage, thème, stats).
Future<PortfolioOfferAccess> loadPortfolioOfferAccess(
  BuildContext context,
) async {
  final subscriptions = context.read<SubscriptionsProvider>();
  if (subscriptions.isAppleReviewFullAccess) {
    return PortfolioOfferAccess.full;
  }
  try {
    return await context.read<SharingApiService>().fetchPortfolioAccess();
  } catch (_) {
    final subscription = subscriptions.subscription;
    final active =
        subscription != null && subscription.audience.isPortfolio;
    if (!active) return PortfolioOfferAccess.locked;
    final entitlements = subscription.entitlements;
    final max = entitlements.hasPortfolio ? entitlements.maxShares : 0;
    final unlimited = max < 0;
    return PortfolioOfferAccess(
      canShare: entitlements.hasPortfolio && max != 0,
      canCustomize: true,
      hasAnalytics: true,
      quota: ShareQuota(
        used: 0,
        max: max,
        canShare: entitlements.hasPortfolio && (unlimited || max > 0),
        isUnlimited: unlimited,
      ),
    );
  }
}

/// Ouvre les offres Portfolio si la capacité demandée n’est pas dans l’offre.
Future<bool> ensurePortfolioCapability(
  BuildContext context, {
  required bool Function(PortfolioOfferAccess access) allowed,
}) async {
  final access = await loadPortfolioOfferAccess(context);
  if (allowed(access)) return true;
  if (!context.mounted) return false;
  await openLinkPremium(context, preferredAudience: OfferAudience.portfolio);
  return false;
}

/// Ouvre les designs pro si personnalisation autorisée, sinon Premium.
Future<void> openProfessionalDesignsOrPremium(
  BuildContext context, {
  required BusinessCard card,
}) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return;

  final team = _teamForCard(context, card);
  if (subscriptionsProvider.canCustomizeCard(card, team: team)) {
    openProfessionalDesigns(context, card: card);
  } else {
    openLinkPremium(context, preferredAudience: _audienceForCard(card));
  }
}

/// Ouvre l’écran de partage au-dessus du parcours en cours.
Future<void> openShareCard(BuildContext context, BusinessCard card) async {
  if (!await ensureCardOfferAccess(context, card)) return;
  if (!context.mounted) return;

  final sharingApi = context.read<SharingApiService>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => DarkModalScope(
            child: Provider<SharingApiService>.value(
              value: sharingApi,
              child: ShareCardScreen(card: card),
            ),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Partage du portfolio : fermé sans abonnement Portfolio valide.
Future<void> openSharePortfolio(BuildContext context, BusinessCard card) async {
  if (!await ensurePortfolioCapability(
    context,
    allowed: (access) => access.canShare,
  )) {
    return;
  }
  if (!context.mounted) return;

  final sharingApi = context.read<SharingApiService>();
  final cardsApi = context.read<CardsApiService>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => MultiProvider(
            providers: [
              Provider<SharingApiService>.value(value: sharingApi),
              Provider<CardsApiService>.value(value: cardsApi),
            ],
            child: SharePortfolioScreen(card: card),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Infos du portfolio : photo, parcours, compétences, réalisations.
Future<void> openPortfolioEditor(BuildContext context, BusinessCard card) async {
  final style = await context.read<CardsApiService>().fetchPortfolioStyle(card.id);
  if (!context.mounted) return;

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PortfolioEditorScreen(
            card: card,
            layoutId: style.layoutId,
            colorId: style.colorId,
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Choix du modèle et de la couleur. Crée le portfolio à la validation.
/// Une fois le thème enregistré, le changer exige un abonnement Portfolio.
Future<void> openPortfolioStyle(
  BuildContext context,
  BusinessCard card, {
  bool customizeOnly = false,
}) async {
  if (customizeOnly &&
      !await ensurePortfolioCapability(
        context,
        allowed: (access) => access.canCustomize,
      )) {
    return;
  }
  if (!context.mounted) return;

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PortfolioStyleScreen(
            card: card,
            customizeOnly: customizeOnly,
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran de modification des informations de carte.
Future<void> openEditCardInfo(BuildContext context, {BusinessCard? card}) async {
  await syncOwnedCardsForEditing(context);
  if (!context.mounted) return;
  final cardsProvider = context.read<CardsProvider>();

  final requested = card;
  BusinessCard? target;
  if (requested != null) {
    target = requested;
    for (final item in cardsProvider.cards) {
      if (item.id == requested.id) {
        target = item;
        break;
      }
    }
  } else {
    target = cardsProvider.primaryCard;
  }

  final selected = target;
  if (selected == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.editCardNoCard)));
    return;
  }

  final cardsApi = context.read<CardsApiService>();
  final authProvider = context.read<AuthProvider>();
  final uploadsApi = context.read<UploadsApiService>();
  final teamsProvider = context.read<TeamsProvider>();
  final subscriptionsProvider = context.read<SubscriptionsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              Provider<UploadsApiService>.value(value: uploadsApi),
              ChangeNotifierProvider<CardsProvider>.value(value: cardsProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<TeamsProvider>.value(value: teamsProvider),
              ChangeNotifierProvider<SubscriptionsProvider>.value(
                value: subscriptionsProvider,
              ),
            ],
            child: EditCardInfoScreen(card: selected),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran de personnalisation de carte (styles / couleurs : gratuit).
Future<void> openCustomizeCard(BuildContext context, BusinessCard card) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  // Rafraîchir les droits pour le bandeau designs pro, sans bloquer l’écran.
  unawaited(subscriptionsProvider.refresh());

  final cardsApi = context.read<CardsApiService>();
  final cardsProvider = context.read<CardsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              ChangeNotifierProvider<CardsProvider>.value(value: cardsProvider),
              ChangeNotifierProvider<SubscriptionsProvider>.value(
                value: subscriptionsProvider,
              ),
            ],
            child: CustomizeCardScreen(card: card),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran de détail « Ma carte ».
Future<void> openMyCardScreen(BuildContext context, BusinessCard card) {
  final cardsProvider = context.read<CardsProvider>();
  final teamsProvider = context.read<TeamsProvider>();
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  final cardsApi = context.read<CardsApiService>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              ChangeNotifierProvider<CardsProvider>.value(value: cardsProvider),
              ChangeNotifierProvider<TeamsProvider>.value(value: teamsProvider),
              ChangeNotifierProvider<SubscriptionsProvider>.value(
                value: subscriptionsProvider,
              ),
            ],
            child: MyCardScreen(card: card),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran « Card analytics ».
  Future<void> openCardAnalytics(BuildContext context, BusinessCard card) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return;

  final team = _teamForCard(context, card);
  if (!await ensureOfferCapability(
    context,
    allowed: subscriptionsProvider.canViewAnalyticsFor(card, team: team),
    preferredAudience: _audienceForCard(card),
  )) {
    return;
  }
  if (!context.mounted) return;

  final cardsApi = context.read<CardsApiService>();
  final teamsProvider = context.read<TeamsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              ChangeNotifierProvider<SubscriptionsProvider>.value(
                value: subscriptionsProvider,
              ),
              ChangeNotifierProvider<TeamsProvider>.value(value: teamsProvider),
            ],
            child: CardAnalyticsScreen(card: card),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran « Vues de la carte » (liste des visiteurs).
Future<void> openCardVisitors(BuildContext context, BusinessCard card) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return;

  final team = _teamForCard(context, card);
  if (!await ensureOfferCapability(
    context,
    allowed: subscriptionsProvider.canViewVisitorsFor(card, team: team),
    preferredAudience: _audienceForCard(card),
  )) {
    return;
  }
  if (!context.mounted) return;

  final cardsApi = context.read<CardsApiService>();
  final contactsProvider = context.read<ContactsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => MultiProvider(
            providers: [
              Provider<CardsApiService>.value(value: cardsApi),
              ChangeNotifierProvider<ContactsProvider>.value(
                value: contactsProvider,
              ),
            ],
            child: CardVisitorsScreen(card: card),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre le détail d’un visiteur de carte.
Future<void> openCardVisitorDetail(
  BuildContext context, {
  required BusinessCard card,
  required CardVisitor visitor,
}) {
  final contactsProvider = context.read<ContactsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider<ContactsProvider>.value(
            value: contactsProvider,
            child: CardVisitorDetailScreen(card: card, visitor: visitor),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre la fiche d’un contact.
Future<void> openContactDetail(BuildContext context, LinkContact contact) {
  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ContactDetailScreen(contact: contact),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre l’écran d’ajout au Wallet.
Future<void> openWalletScreen(BuildContext context, BusinessCard card) async {
  final subscriptionsProvider = context.read<SubscriptionsProvider>();
  await subscriptionsProvider.refresh();
  if (!context.mounted) return;

  final team = _teamForCard(context, card);
  if (!await ensureOfferCapability(
    context,
    allowed: subscriptionsProvider.canUseWalletFor(card, team: team),
    preferredAudience: _audienceForCard(card),
  )) {
    return;
  }
  if (!context.mounted) return;

  final walletService = context.read<WalletPlatformService>();
  final teamsProvider = context.read<TeamsProvider>();

  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => DarkModalScope(
            child: MultiProvider(
              providers: [
                Provider<WalletPlatformService>.value(value: walletService),
                ChangeNotifierProvider<TeamsProvider>.value(
                  value: teamsProvider,
                ),
              ],
              child: AddToWalletScreen(card: card),
            ),
          ),
        ),
      ) ??
      Future<void>.value();
}

/// Ouvre la politique de confidentialité.
Future<void> openPrivacyPolicy(BuildContext context) {
  return rootNavigatorKey.currentState?.push<void>(
        MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
      ) ??
      Future<void>.value();
}
