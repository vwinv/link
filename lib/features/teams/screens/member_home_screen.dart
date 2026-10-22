import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_analytics.dart';
import 'package:linkflutter/features/cards/models/card_visitors.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/features/sharing/share_card_helper.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/models/team_member.dart';
import 'package:linkflutter/features/teams/models/team_seats_quota.dart';
import 'package:linkflutter/features/teams/screens/add_team_member_screen.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

enum _MemberTab { card, team }

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  var _tab = _MemberTab.card;
  var _loadingExtras = true;
  CardAnalytics _analytics = CardAnalytics.empty;
  List<CardVisitor> _viewers = const [];
  List<TeamMember> _members = const [];
  TeamSeatsQuota _seats = TeamSeatsQuota.empty;

  bool get _canManageMembers {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return false;
    return _members.any(
      (member) => member.userId == userId && member.role.isAdmin,
    );
  }

  bool get _isTeamOwner {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return false;
    return _members.any(
      (member) =>
          member.userId == userId && member.role == TeamMemberRole.owner,
    );
  }

  bool _canRemoveMember(TeamMember member) {
    if (!_canManageMembers) return false;
    if (member.role == TeamMemberRole.owner) return false;
    if (_isTeamOwner) return true;
    return member.role == TeamMemberRole.member || member.isPendingInvite;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExtras());
  }

  Future<void> _reloadMembers() async {
    final team = context.read<TeamsProvider>().memberTeam ??
        context.read<TeamsProvider>().myTeam;
    if (team == null) return;
    try {
      final result =
          await context.read<TeamsApiService>().fetchTeamMembers(team.id);
      if (!mounted) return;
      setState(() {
        _members = result.members;
        _seats = result.seats;
      });
    } catch (_) {}
  }

  Future<void> _openAddMember() async {
    final team = context.read<TeamsProvider>().memberTeam ??
        context.read<TeamsProvider>().myTeam;
    if (team == null) return;
    final l10n = context.l10n;

    if (!_seats.canAddMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _seats.max <= 0
                ? l10n.teamMembersSubscriptionRequired
                : l10n.teamMembersSeatLimitReached(_seats.max),
          ),
        ),
      );
      return;
    }

    final teamsApi = context.read<TeamsApiService>();
    final uploadsApi = context.read<UploadsApiService>();

    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            Provider<TeamsApiService>.value(value: teamsApi),
            Provider<UploadsApiService>.value(value: uploadsApi),
          ],
          child: AddTeamMemberScreen(
            team: team,
            canAssignAdminRole: _isTeamOwner,
          ),
        ),
      ),
    );

    if (added == true && mounted) {
      await _reloadMembers();
    }
  }

  Future<void> _confirmRemoveMember(TeamMember member) async {
    final team = context.read<TeamsProvider>().memberTeam ??
        context.read<TeamsProvider>().myTeam;
    if (team == null || !_canRemoveMember(member)) return;

    final l10n = context.l10n;
    final isPending = member.isPendingInvite;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isPending
              ? l10n.teamMembersCancelInviteTitle
              : l10n.teamMembersRemoveTitle,
        ),
        content: Text(
          isPending
              ? l10n.teamMembersCancelInviteMessage(member.fullName)
              : l10n.teamMembersRemoveMessage(member.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              isPending ? l10n.teamMembersCancelInvite : l10n.commonDelete,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final teamsApi = context.read<TeamsApiService>();

    try {
      if (isPending) {
        await teamsApi.cancelTeamInvitation(
          teamId: team.id,
          inviteId: member.id,
        );
      } else {
        await teamsApi.removeTeamMember(
          teamId: team.id,
          memberId: member.id,
        );
      }
      if (!mounted) return;
      await _reloadMembers();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isPending
                ? l10n.teamMembersCancelInviteSuccess
                : l10n.teamMembersRemoveSuccess,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMembersRemoveError)),
      );
    }
  }

  Future<void> _loadExtras() async {
    final cards = context.read<CardsProvider>();
    final teams = context.read<TeamsProvider>();
    final user = context.read<AuthProvider>().user;
    final team = teams.memberTeam ?? teams.myTeam;

    if (!mounted) return;
    setState(() => _loadingExtras = true);

    // Crée la carte membre si absente (après acceptation d’invite).
    if (team != null && user != null && cards.memberCard(teamId: team.id) == null) {
      try {
        await cards
            .ensureMemberCardForTeam(team, owner: user)
            .timeout(const Duration(seconds: 12));
      } catch (_) {}
    }

    if (!mounted) return;
    final card = team != null
        ? cards.memberCard(teamId: team.id)
        : cards.memberCard();

    try {
      final cardsApi = context.read<CardsApiService>();
      final teamsApi = context.read<TeamsApiService>();

      CardAnalytics analytics = CardAnalytics.empty;
      List<CardVisitor> viewers = const [];
      List<TeamMember> members = const [];

      if (card != null) {
        final canAnalytics =
            context.read<SubscriptionsProvider>().canViewAnalyticsFor(
                  card,
                  team: team,
                );
        final canVisitors =
            context.read<SubscriptionsProvider>().canViewVisitorsFor(
                  card,
                  team: team,
                );

        if (canAnalytics) {
          try {
            analytics = await cardsApi.fetchCardAnalytics(card.id, days: 30);
          } catch (_) {}
        }
        if (canVisitors) {
          try {
            final result = await cardsApi.fetchCardVisitors(card.id);
            viewers = result.visitors.take(4).toList();
            if (analytics.views == 0 && analytics.uniqueVisitors == 0) {
              analytics = analytics.copyWith(
                views: result.summary.views,
                uniqueVisitors: result.summary.uniqueVisitors,
              );
            }
          } catch (_) {}
        }
      }

      if (team != null) {
        try {
          final result = await teamsApi.fetchTeamMembers(team.id);
          members = result.members;
          if (!mounted) return;
          setState(() => _seats = result.seats);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _analytics = analytics;
        _viewers = viewers;
        _members = members;
        _loadingExtras = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingExtras = false);
    }
  }

  String _relativeDay(DateTime viewedAt) {
    final l10n = context.l10n;
    final local = viewedAt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return l10n.memberHomeToday;
    if (diff == 1) return l10n.memberHomeYesterday;
    return l10n.memberHomeDaysAgo(diff);
  }

  Future<void> _showWorkspaceMenu() async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(l10n.workspaceSwitchToPersonal),
              onTap: () => Navigator.pop(ctx, 'personal'),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(l10n.workspaceStayMember),
              onTap: () => Navigator.pop(ctx, 'member'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (choice == 'personal' && mounted) {
      await switchToPersonalWorkspace(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthProvider>().user;
    final cards = context.watch<CardsProvider>();
    final teams = context.watch<TeamsProvider>();
    final team = teams.memberTeam ?? teams.myTeam;
    final card = team != null
        ? cards.memberCard(teamId: team.id)
        : cards.memberCard();

    final title = _tab == _MemberTab.card
        ? l10n.memberHomeMyCardTitle
        : l10n.memberHomeTeamTitle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => switchToPersonalWorkspace(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.rs(17),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (team != null)
                          Text(
                            team.name,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.rs(12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showWorkspaceMenu,
                    child: Row(
                      children: [
                        _UserAvatar(userInitials: user?.initials ?? '?'),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _TabLabel(
                    label: l10n.memberHomeCardTab,
                    selected: _tab == _MemberTab.card,
                    onTap: () => setState(() => _tab = _MemberTab.card),
                  ),
                  const SizedBox(width: 28),
                  _TabLabel(
                    label: l10n.memberHomeTeamTab,
                    selected: _tab == _MemberTab.team,
                    onTap: () => setState(() => _tab = _MemberTab.team),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    cards.load(),
                    teams.load(),
                  ]);
                  await _loadExtras();
                },
                child: _tab == _MemberTab.card
                    ? _CardTab(
                        card: card,
                        team: team,
                        analytics: _analytics,
                        viewers: _viewers,
                        loading: _loadingExtras,
                        relativeDay: _relativeDay,
                      )
                    : _TeamTab(
                        team: team,
                        members: _members,
                        loading: _loadingExtras,
                        canManage: _canManageMembers,
                        canRemoveMember: _canRemoveMember,
                        onAddMember: _openAddMember,
                        onRemoveMember: _confirmRemoveMember,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.bleu_primaire
                    : AppColors.textSecondary,
                fontSize: context.rs(14),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2.5,
              width: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.bleu_primaire : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.userInitials});

  final String userInitials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFAF52DE),
      child: Text(
        userInitials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardTab extends StatelessWidget {
  const _CardTab({
    required this.card,
    required this.team,
    required this.analytics,
    required this.viewers,
    required this.loading,
    required this.relativeDay,
  });

  final BusinessCard? card;
  final Team? team;
  final CardAnalytics analytics;
  final List<CardVisitor> viewers;
  final bool loading;
  final String Function(DateTime) relativeDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (card == null)
          Padding(
            padding: const EdgeInsets.all(32),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    l10n.memberHomeNoCard,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(14),
                    ),
                  ),
          )
        else ...[
          CardPreview(
            fullName: card!.fullName,
            initials: card!.initials,
            avatarUrl: card!.avatarImageUrl,
            email: card!.email ?? '',
            phone: card!.phone,
            address: card!.address,
            subtitle: card!.subtitle,
            style: card!.theme.style,
            showQr: card!.theme.showQrCode,
            qrData: ShareCardHelper.publicUrl(card!.slug),
            companyLogoUrl: card!.companyLogoImageUrl(team),
            tagLabel: card!.kind.tagLabelL10n(l10n),
            cardBadge: card!.theme.cardBadge,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => openShareCard(context, card!),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bleu_primaire,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(l10n.memberHomeShare),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => openWalletScreen(context, card!),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.wallet_outlined, size: 18),
                    label: Text(l10n.memberHomeWallet),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.visibility_outlined,
                    value: '${analytics.views}',
                    label: l10n.memberHomeTotalViews,
                  ),
                ),
                Container(width: 1, height: 44, color: const Color(0xFFE5E5EA)),
                Expanded(
                  child: _StatCell(
                    icon: Icons.groups_outlined,
                    value: '${analytics.uniqueVisitors}',
                    label: l10n.memberHomeUniquePeople,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.memberHomeViewersTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => openCardVisitors(context, card!),
                child: Text(
                  l10n.memberHomeSeeAll,
                  style: TextStyle(
                    color: AppColors.bleu_primaire,
                    fontSize: context.rs(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.memberHomeNoViewers,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.rs(14),
                ),
              ),
            )
          else
            ...viewers.map(
              (v) => _ViewerRow(
                visitor: v,
                relativeDay: relativeDay(v.viewedAt),
                onTap: () => openCardVisitorDetail(
                  context,
                  card: card!,
                  visitor: v,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.bleu_primaire, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.rs(22),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: context.rs(12),
          ),
        ),
      ],
    );
  }
}

class _ViewerRow extends StatelessWidget {
  const _ViewerRow({
    required this.visitor,
    required this.relativeDay,
    required this.onTap,
  });

  final CardVisitor visitor;
  final String relativeDay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(visitor.avatarUrl);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.bleu_clair,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      visitor.initials,
                      style: const TextStyle(
                        color: AppColors.bleu_primaire,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor.displayName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (visitor.subtitle.isNotEmpty)
                    Text(
                      visitor.subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(12),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              relativeDay,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(12),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamTab extends StatelessWidget {
  const _TeamTab({
    required this.team,
    required this.members,
    required this.loading,
    required this.canManage,
    required this.canRemoveMember,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  final Team? team;
  final List<TeamMember> members;
  final bool loading;
  final bool canManage;
  final bool Function(TeamMember) canRemoveMember;
  final VoidCallback onAddMember;
  final Future<void> Function(TeamMember) onRemoveMember;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleMembers = canManage
        ? members
        : members.where((m) => !m.isPendingInvite).toList();
    final activeCount =
        members.where((m) => m.status == TeamMemberStatus.active).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Text(
          l10n.memberHomeTeamOverview,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.rs(16),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5EA)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bleu_clair,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.bleu_primaire,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${loading ? '-' : activeCount}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(28),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.memberHomeMembersLabel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.memberHomeMembersListTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.rs(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (canManage)
              TextButton.icon(
                onPressed: onAddMember,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: Text(l10n.teamMembersAddTitle),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.bleu_primaire,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (visibleMembers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '-',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(14),
              ),
            ),
          )
        else
          ...visibleMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final removable = canRemoveMember(member);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: member.avatarColorForIndex(index),
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.fullName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: context.rs(15),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            member.isPendingInvite
                                ? '${member.subtitle} - ${member.status.label}'
                                : member.subtitle,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.rs(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (removable)
                      IconButton(
                        onPressed: () => onRemoveMember(member),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        tooltip: member.isPendingInvite
                            ? l10n.teamMembersCancelInvite
                            : l10n.teamMembersRemoveMember,
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
