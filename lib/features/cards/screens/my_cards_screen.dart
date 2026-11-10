import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_analytics.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/features/cards/models/portfolio_profile.dart';
import 'package:linkflutter/features/cards/models/portfolio_stats.dart';
import 'package:linkflutter/features/cards/models/portfolio_style.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/cards/widgets/card_preview_badge.dart';
import 'package:linkflutter/features/cards/widgets/portfolio_home_preview.dart';
import 'package:linkflutter/features/cards/widgets/portfolio_stats_sheet.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/card_analytics_refresh_notifier.dart';
import 'package:linkflutter/features/sharing/models/share_quota.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

enum _CardScope { personal, professional, portfolio }

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen>
    with WidgetsBindingObserver {
  static const _analyticsRefreshInterval = Duration(seconds: 4);
  static const _burstRefreshInterval = Duration(seconds: 2);
  static const _burstRefreshCount = 4;

  _CardScope _scope = _CardScope.personal;
  CardAnalytics _analytics = CardAnalytics.empty;
  String? _portfolioCardId;
  PortfolioStyle? _portfolioStyle;
  PortfolioProfile? _portfolioProfile;
  PortfolioOfferAccess? _portfolioAccess;
  var _portfolioLoading = false;
  String? _trackedAnalyticsCardId;
  Timer? _analyticsTimer;
  Timer? _burstAnalyticsTimer;
  CardAnalyticsRefreshNotifier? _analyticsRefreshNotifier;

  @override
  void deactivate() {
    _analyticsTimer?.cancel();
    _burstAnalyticsTimer?.cancel();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    final cardId = _trackedAnalyticsCardId;
    if (cardId == null) return;
    _restartAnalyticsTimer();
    _reloadAnalytics(cardId);
    _scheduleBurstAnalyticsRefresh(cardId);
  }

  void _restartAnalyticsTimer() {
    _analyticsTimer?.cancel();
    _analyticsTimer = Timer.periodic(
      _analyticsRefreshInterval,
      (_) => _reloadAnalytics(_trackedAnalyticsCardId),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restartAnalyticsTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialScope();
      _bindAnalyticsRefreshNotifier();
    });
  }

  @override
  void dispose() {
    _analyticsRefreshNotifier?.removeListener(_onAnalyticsRefreshRequested);
    _analyticsTimer?.cancel();
    _burstAnalyticsTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _bindAnalyticsRefreshNotifier() {
    if (!mounted) return;

    final notifier = context.read<CardAnalyticsRefreshNotifier>();
    if (_analyticsRefreshNotifier == notifier) return;

    _analyticsRefreshNotifier?.removeListener(_onAnalyticsRefreshRequested);
    _analyticsRefreshNotifier = notifier;
    notifier.addListener(_onAnalyticsRefreshRequested);
  }

  void _onAnalyticsRefreshRequested() {
    final notifier = _analyticsRefreshNotifier;
    final sharesDelta = notifier?.consumeSharesDelta() ?? 0;
    if (sharesDelta > 0 && mounted) {
      setState(() {
        _analytics = CardAnalytics(
          views: _analytics.views,
          shares: _analytics.shares + sharesDelta,
          saved: _analytics.saved,
        );
      });
    }
    if (!mounted || _trackedAnalyticsCardId == null) return;
    _reloadAnalytics(_trackedAnalyticsCardId);
  }

  void _scheduleBurstAnalyticsRefresh(String cardId) {
    _burstAnalyticsTimer?.cancel();
    var remaining = _burstRefreshCount;
    _burstAnalyticsTimer = Timer.periodic(_burstRefreshInterval, (timer) {
      if (!mounted || _trackedAnalyticsCardId != cardId) {
        timer.cancel();
        return;
      }

      _reloadAnalytics(cardId);
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final cardId = _trackedAnalyticsCardId;
      if (cardId == null) return;
      _reloadAnalytics(cardId);
      _scheduleBurstAnalyticsRefresh(cardId);
    }
  }

  void _scheduleAnalyticsLoad(BusinessCard? card) {
    if (card == null) return;
    if (_trackedAnalyticsCardId == card.id) return;
    _trackedAnalyticsCardId = card.id;
    _loadAnalytics(card.id);
  }

  Future<void> _reloadAnalytics(String? cardId) async {
    if (cardId == null || !mounted) return;
    await _loadAnalytics(cardId);
  }

  Future<void> _loadAnalytics(String cardId) async {
    try {
      final analytics = await context
          .read<CardsApiService>()
          .fetchCardAnalytics(cardId);
      if (!mounted || _trackedAnalyticsCardId != cardId) return;
      setState(() => _analytics = analytics);
    } catch (_) {
      // Conserve les dernières valeurs affichées en cas d’erreur réseau.
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<CardsProvider>().load(),
      context.read<TeamsProvider>().load(),
      context.read<ContactsProvider>().load(),
    ]);
    if (!mounted) return;

    final card = _cardForScope(context.read<CardsProvider>(), _scope);
    if (card != null) {
      await _loadAnalytics(card.id);
      if (_scope == _CardScope.portfolio) {
        await _loadPortfolioPresence(card.id);
      }
    }
  }

  Future<void> _loadPortfolioPresence(String cardId) async {
    setState(() {
      _portfolioLoading = true;
      if (_portfolioCardId != cardId) {
        _portfolioProfile = null;
        _portfolioStyle = null;
        _portfolioAccess = null;
      }
      _portfolioCardId = cardId;
    });
    try {
      final api = context.read<CardsApiService>();
      final sharingApi = context.read<SharingApiService>();
      final reviewAccess =
          context.read<SubscriptionsProvider>().isAppleReviewFullAccess;
      final style = await api.fetchPortfolioStyle(cardId);
      PortfolioProfile? profile;
      PortfolioOfferAccess? access;
      if (style.exists) {
        try {
          profile = await api.fetchPortfolioProfile(cardId);
        } catch (_) {
          profile = null;
        }
        if (reviewAccess) {
          access = PortfolioOfferAccess.full;
        } else {
          try {
            access = await sharingApi.fetchPortfolioAccess();
          } catch (_) {
            access = _portfolioAccess;
          }
        }
      }
      if (!mounted || _portfolioCardId != cardId) return;
      setState(() {
        _portfolioStyle = style;
        _portfolioProfile = style.exists ? profile : null;
        _portfolioAccess = style.exists ? access : null;
        _portfolioLoading = false;
      });
    } catch (_) {
      if (!mounted || _portfolioCardId != cardId) return;
      setState(() => _portfolioLoading = false);
    }
  }

  Future<void> _runPortfolioAction(
    BusinessCard card,
    Future<void> Function() action,
  ) async {
    await action();
    if (!mounted) return;
    await _loadPortfolioPresence(card.id);
  }

  Future<void> _afterCardAction(
    BusinessCard card,
    Future<void> Function() action,
  ) async {
    await action();
    if (!mounted) return;
    await _reloadAnalytics(card.id);
    _scheduleBurstAnalyticsRefresh(card.id);
  }

  Future<void> _openPortfolioStats(BusinessCard card) async {
    if (!await ensurePortfolioCapability(
      context,
      allowed: (access) => access.hasAnalytics,
    )) {
      return;
    }
    if (!mounted) return;
    var stats = PortfolioStats.empty;
    try {
      stats = await context.read<CardsApiService>().fetchPortfolioStats(card.id);
    } catch (_) {
      stats = PortfolioStats.empty;
    }
    if (!mounted) return;
    await showPortfolioStatsSheet(
      context,
      visits: stats.siteVisits,
      portfolioClicks: stats.portfolioClicks,
    );
  }

  Future<void> _openMemberAccount(BuildContext context) async {
    await enterMemberWorkspace(context);
  }

  void _syncInitialScope() {
    if (!mounted) return;

    final cardsProvider = context.read<CardsProvider>();
    final teamsProvider = context.read<TeamsProvider>();

    if (!cardsProvider.hasPersonalCard && cardsProvider.hasProfessionalCard) {
      setState(() => _scope = _CardScope.professional);
    } else if (!cardsProvider.hasProfessionalCard &&
        teamsProvider.isTeamOwner) {
      setState(() => _scope = _CardScope.professional);
    }
  }

  Future<void> _createProfessionalCard() async {
    final card = await openSetupProfessionalTeam(context);
    if (!mounted || card == null) return;
    await persistUserWorkspace(context);
    await context.read<CardsProvider>().load(force: true);
    if (!mounted) return;
    await persistUserWorkspace(context);
    setState(() => _scope = _CardScope.professional);
  }

  BusinessCard? _cardForScope(CardsProvider cards, _CardScope scope) {
    return switch (scope) {
      _CardScope.personal => cards.personalCard,
      _CardScope.professional => cards.professionalCard,
      _CardScope.portfolio =>
        cards.professionalCard ?? cards.personalCard ?? cards.memberCard(),
    };
  }

  void _createPersonalCard() {
    context.read<CreateCardProvider>().initFromUser(
      context.read<AuthProvider>().user,
      fromExistingWorkspace: true,
    );
    context.push(RoutePaths.createCard);
  }

  @override
  Widget build(BuildContext context) {
    final cardsProvider = context.watch<CardsProvider>();
    final teamsProvider = context.watch<TeamsProvider>();
    final contactsProvider = context.watch<ContactsProvider>();
    final user = context.watch<AuthProvider>().user;
    final card = _cardForScope(cardsProvider, _scope);
    final team = teamsProvider.myTeam;
    _scheduleAnalyticsLoad(card);

    if (cardsProvider.isLoading && !cardsProvider.hasLoaded && card == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            children: [
              _MyCardsHeader(
                firstName: user?.firstName ?? 'DropOne',
                initials: user?.initials ?? '?',
              ),
              const SizedBox(height: AppSpacing.lg),
              _CardScopeToggle(
                scope: _scope,
                onChanged: (scope) {
                  final nextCard = _cardForScope(cardsProvider, scope);
                  setState(() {
                    _scope = scope;
                    _trackedAnalyticsCardId = null;
                    _analytics = CardAnalytics.empty;
                    if (scope == _CardScope.portfolio &&
                        nextCard != null &&
                        _portfolioCardId != nextCard.id) {
                      _portfolioLoading = true;
                    }
                  });
                  if (nextCard != null) {
                    _trackedAnalyticsCardId = nextCard.id;
                    _loadAnalytics(nextCard.id);
                    if (scope == _CardScope.portfolio &&
                        (_portfolioCardId != nextCard.id || _portfolioStyle == null)) {
                      _loadPortfolioPresence(nextCard.id);
                    }
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_scope == _CardScope.portfolio) ...[
                if (card != null &&
                    _portfolioCardId == card.id &&
                    _portfolioStyle?.exists == true) ...[
                  Text(
                    context.l10n.portfolioHomeHeadline,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(22),
                      fontWeight: AppFontWeight.bold,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CardPreviewBadge(
                    dark: true,
                    label: context.l10n.homePreviewMyPortfolio,
                    onPreview: () => context.push(
                      '${RoutePaths.publicPortfolio}/${card.slug}?preview=1',
                    ),
                    child: _LivePortfolioPreview(
                      card: card,
                      profile: _portfolioProfile,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PortfolioActionRow(
                    shareLocked: _portfolioAccess != null &&
                        !_portfolioAccess!.canShare,
                    customizeLocked: _portfolioAccess != null &&
                        !_portfolioAccess!.canCustomize,
                    onShare: () => _runPortfolioAction(
                      card,
                      () => openSharePortfolio(context, card),
                    ),
                    onEdit: () => _runPortfolioAction(
                      card,
                      () => openPortfolioEditor(context, card),
                    ),
                    onCustomize: () => _runPortfolioAction(
                      card,
                      () => openPortfolioStyle(
                        context,
                        card,
                        customizeOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _HomeStatsCta(
                    subtitle: context.l10n.portfolioStatsSubtitle,
                    locked: _portfolioAccess != null &&
                        !_portfolioAccess!.hasAnalytics,
                    onTap: () => _openPortfolioStats(card),
                  ),
                ] else if (_portfolioLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  const PortfolioHomePreview(),
                  const SizedBox(height: AppSpacing.lg),
                  _CreatePortfolioCard(
                    onCreate: () {
                      if (card == null) {
                        _createPersonalCard();
                        return;
                      }
                      _runPortfolioAction(
                        card,
                        () => openPortfolioStyle(context, card),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ] else if (card != null) ...[
                CardPreviewBadge(
                  label: context.l10n.homePreviewMyCard,
                  onPreview: () => context.push(
                    '${RoutePaths.publicCard}/${card.slug}?preview=1',
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _afterCardAction(
                        card,
                        () => openMyCardScreen(context, card),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: CardPreview(
                        fullName: card.fullName,
                        initials: card.initials,
                        avatarUrl: card.avatarImageUrl,
                        email: card.email ?? '',
                        phone: card.phone,
                        address: card.kind.isTeamLinked ? card.address : null,
                        subtitle: card.subtitle,
                        style: card.theme.style,
                        showQr: card.theme.showQrCode,
                        qrData: ShareCardHelper.publicUrl(card.slug),
                        companyLogoUrl: card.isProfessional
                            ? card.companyLogoImageUrl(team)
                            : null,
                        tagLabel: card.kind.tagLabelL10n(context.l10n),
                        cardBadge: card.theme.cardBadge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CardActionRow(
                  onShare: () => _afterCardAction(
                    card,
                    () => openShareCard(context, card),
                  ),
                  onEdit: () => _afterCardAction(
                    card,
                    () => openCustomizeCard(context, card),
                  ),
                  onWallet: () => _afterCardAction(
                    card,
                    () => openWalletScreen(context, card),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (teamsProvider.shouldShowMemberSpaceCta) ...[
                  _HomeMemberCta(
                    onTap: () => _openMemberAccount(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _HomeStatsCta(
                  onTap: () => _afterCardAction(
                    card,
                    () => openCardAnalytics(context, card),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ] else if (_scope == _CardScope.professional) ...[
                _MissingProfessionalCardCard(
                  hasTeam: context.watch<TeamsProvider>().isTeamOwner,
                  canEditTeam: context.watch<TeamsProvider>().isTeamOwner,
                  onCreate: _createProfessionalCard,
                  onEditTeam: () => openSetupTeam(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ] else ...[
                _MissingPersonalCardCard(onCreate: _createPersonalCard),
                const SizedBox(height: AppSpacing.xxl),
              ],
              if (_scope != _CardScope.portfolio)
                _SharedContactsSection(contacts: contactsProvider.recentContacts),
            ],
          ),
        ),
      ),
    );
  }
}

/// Libellé blanc à cheval sur le coin haut droit : une moitié au-dessus, l’autre sur la carte.
const _homeTileHeight = 76.0;

class _CardActionRow extends StatelessWidget {
  const _CardActionRow({
    required this.onShare,
    required this.onEdit,
    required this.onWallet,
  });

  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: l10n.commonShare,
            icon: Icons.ios_share_rounded,
            isPrimary: true,
            onTap: onShare,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            label: l10n.commonEdit,
            icon: Icons.edit_outlined,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            label: l10n.walletTitle,
            icon: Icons.account_balance_wallet_outlined,
            onTap: onWallet,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.locked = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final fill = isPrimary
        ? AppColors.bleu_primaire
        : AppColors.iconBgMuted;
    final foreground = isPrimary ? AppColors.onPrimary : AppColors.textPrimary;

    return SizedBox(
      height: _homeTileHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: fill.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: foreground),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: context.rs(12),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                if (locked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: foreground.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LivePortfolioPreview extends StatelessWidget {
  const _LivePortfolioPreview({required this.card, required this.profile});

  final BusinessCard card;
  final PortfolioProfile? profile;

  @override
  Widget build(BuildContext context) {
    final saved = profile;
    final first = saved?.firstName.trim() ?? '';
    final last = saved?.lastName.trim() ?? '';
    final savedName = '$first $last'.trim();
    final name = savedName.isNotEmpty ? savedName : card.fullName;
    final savedTitle = saved?.title.trim() ?? '';
    final job = card.jobTitle?.trim() ?? '';
    final role = savedTitle.isNotEmpty
        ? savedTitle
        : (job.isNotEmpty ? job : card.subtitle);
    final photo = ApiConfig.resolvePublicAssetUrl(saved?.photoUrl) ??
        card.avatarImageUrl;
    PortfolioExperienceItem? journey;
    for (final item in saved?.experiences ?? const <PortfolioExperienceItem>[]) {
      if (item.role.trim().isNotEmpty) {
        journey = item;
        break;
      }
    }
    final skills = (saved?.skills ?? const <PortfolioSkillItem>[])
        .where((item) => item.name.trim().isNotEmpty)
        .take(3)
        .map(
          (item) => PortfolioPreviewSkill(
            item.name.trim(),
            (item.level.clamp(0, 100)) / 100,
          ),
        )
        .toList();

    return PortfolioHomePreview(
      slug: card.slug,
      name: name.isEmpty ? '—' : name,
      role: role,
      photoUrl: photo,
      journeyTitle: journey?.role.trim(),
      journeyMeta: journey == null || journey.subtitle.isEmpty
          ? null
          : journey.subtitle,
      skills: skills,
    );
  }
}

class _PortfolioActionRow extends StatelessWidget {
  const _PortfolioActionRow({
    required this.onShare,
    required this.onEdit,
    required this.onCustomize,
    this.shareLocked = false,
    this.customizeLocked = false,
  });

  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onCustomize;
  final bool shareLocked;
  final bool customizeLocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: l10n.commonShare,
            icon: Icons.ios_share_rounded,
            isPrimary: true,
            locked: shareLocked,
            onTap: onShare,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            label: l10n.commonEdit,
            icon: Icons.edit_outlined,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            label: l10n.customizeTitle,
            icon: Icons.palette_outlined,
            locked: customizeLocked,
            onTap: onCustomize,
          ),
        ),
      ],
    );
  }
}

class _CreatePortfolioCard extends StatelessWidget {
  const _CreatePortfolioCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.bleu_primaire,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.portfolioHomeHeadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.rs(AppFontSize.lg),
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.portfolioEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(AppFontSize.sm),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(l10n.portfolioCreate),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingPersonalCardCard extends StatelessWidget {
  const _MissingPersonalCardCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.credit_card_outlined,
            color: AppColors.bleu_primaire,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.myCardsPersonalTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.rs(AppFontSize.lg),
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.myCardsPersonalSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(AppFontSize.sm),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(l10n.myCardsCreatePersonal),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingProfessionalCardCard extends StatelessWidget {
  const _MissingProfessionalCardCard({
    required this.hasTeam,
    required this.canEditTeam,
    required this.onCreate,
    required this.onEditTeam,
  });

  final bool hasTeam;
  final bool canEditTeam;
  final VoidCallback onCreate;
  final VoidCallback onEditTeam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.business_center_outlined,
            color: AppColors.bleu_primaire,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.myCardsProTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.rs(AppFontSize.lg),
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasTeam ? l10n.myCardsProWithTeam : l10n.myCardsProWithoutTeam,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(AppFontSize.sm),
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                hasTeam ? l10n.myCardsContinueSetup : l10n.myCardsSetupTeam,
              ),
            ),
          ),
          if (canEditTeam) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onEditTeam,
              child: Text(l10n.myCardsEditTeam),
            ),
          ],
        ],
      ),
    );
  }
}

class _MyCardsHeader extends StatelessWidget {
  const _MyCardsHeader({
    required this.firstName,
    required this.initials,
  });

  final String firstName;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.myCardsGreeting(firstName),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.rs(AppFontSize.md),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.myCardsTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.rs(28),
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.bleu_primaire,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => context.go(RoutePaths.profile),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: AppFontWeight.bold,
                  fontSize: AppFontSize.sm,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardScopeToggle extends StatelessWidget {
  const _CardScopeToggle({
    required this.scope,
    required this.onChanged,
  });

  final _CardScope scope;
  final ValueChanged<_CardScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScopeChip(
              label: l10n.cardScopePersonalShort,
              isSelected: scope == _CardScope.personal,
              onTap: () => onChanged(_CardScope.personal),
            ),
          ),
          Expanded(
            child: _ScopeChip(
              label: l10n.cardScopeProfessionalShort,
              isSelected: scope == _CardScope.professional,
              onTap: () => onChanged(_CardScope.professional),
            ),
          ),
          Expanded(
            child: _ScopeChip(
              label: l10n.portfolioScope,
              isSelected: scope == _CardScope.portfolio,
              onTap: () => onChanged(_CardScope.portfolio),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.bleu_primaire : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              fontSize: context.rs(13),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeStatsCta extends StatelessWidget {
  const _HomeStatsCta({
    required this.onTap,
    this.subtitle,
    this.locked = false,
  });

  final VoidCallback onTap;
  final String? subtitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.bleu_primaire,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.myCardsSeeStats,
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: context.rs(AppFontSize.md),
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle ?? l10n.myCardsSeeStatsSubtitle,
                          style: TextStyle(
                            color: AppColors.onPrimary.withValues(alpha: 0.85),
                            fontSize: context.rs(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 8,
              right: 14,
              child: _Sparkles(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMemberCta extends StatelessWidget {
  const _HomeMemberCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.bleu_primaire, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bleu_clair,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.bleu_primaire,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.myCardsMemberLogin,
                      style: TextStyle(
                        color: AppColors.bleu_primaire,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.myCardsMemberLoginSubtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(12),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.bleu_primaire,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkles extends StatelessWidget {
  const _Sparkles();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 22,
      child: CustomPaint(painter: _SparklesPainter()),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7EB6FF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    void dash(Offset start, Offset end) {
      canvas.drawLine(start, end, paint);
    }

    dash(Offset(size.width * 0.2, size.height * 0.75), Offset(size.width * 0.05, size.height * 0.35));
    dash(Offset(size.width * 0.55, size.height * 0.7), Offset(size.width * 0.45, size.height * 0.15));
    dash(Offset(size.width * 0.85, size.height * 0.65), Offset(size.width * 0.95, size.height * 0.2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SharedContactsSection extends StatelessWidget {
  const _SharedContactsSection({required this.contacts});

  final List<LinkContact> contacts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.myCardsRecentContacts,
              style: TextStyle(
                color: AppColors.textTertiaire,
                fontSize: context.rs(12),
                fontWeight: AppFontWeight.semiBold,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(RoutePaths.contacts),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.bleu_primaire,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.myCardsSeeAll),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              l10n.myCardsNoContactsDot,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(AppFontSize.sm),
              ),
            ),
          )
        else
          for (final contact in contacts) ...[
            _SharedContactTile(contact: contact),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _SharedContactTile extends StatelessWidget {
  const _SharedContactTile({required this.contact});

  final LinkContact contact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () => openContactDetail(context, contact),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: contact.avatarColor,
                child: Text(
                  contact.initials,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: AppFontWeight.bold,
                    fontSize: AppFontSize.sm,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    if (contact.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                contact.shortAddedAgo.isNotEmpty
                    ? contact.shortAddedAgo
                    : contact.addedAgo,
                style: TextStyle(
                  color: AppColors.textTertiaire,
                  fontSize: context.rs(12),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaire,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
