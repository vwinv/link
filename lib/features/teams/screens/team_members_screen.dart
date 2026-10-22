import 'package:flutter/material.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/teams/screens/add_team_member_screen.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/models/team_member.dart';
import 'package:linkflutter/features/teams/models/team_seats_quota.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:provider/provider.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({
    required this.team,
    super.key,
    this.showBackButton = true,
  });

  final Team team;
  final bool showBackButton;

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  List<TeamMember> _members = [];
  TeamSeatsQuota _seats = TeamSeatsQuota.empty;
  late Team _team;
  var _isLoading = true;
  var _isContinuing = false;

  bool get _hasAvailableSeats => _seats.canAddMember;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTeam();
      _loadMembers();
    });
  }

  Future<void> _refreshTeam() async {
    try {
      final team = await context.read<TeamsApiService>().fetchTeam(_team.id);
      if (!mounted) return;
      setState(() => _team = team);
    } catch (_) {
      // Conserve l'équipe passée en navigation.
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final l10n = context.l10n;

    try {
      final result = await context
          .read<TeamsApiService>()
          .fetchTeamMembers(_team.id);
      if (!mounted) return;
      setState(() {
        _members = result.members;
        _seats = result.seats;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.teamMembersLoadError)),
      );
    }
  }

  Future<void> _openAddMemberSheet() async {
    final l10n = context.l10n;
    if (!_hasAvailableSeats) {
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
            team: _team,
            canAssignAdminRole: _isTeamOwner,
          ),
        ),
      ),
    );

    if (added == true) {
      await _loadMembers();
    }
  }

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
    // Admin : uniquement les membres (pas d’autres admins).
    return member.role == TeamMemberRole.member || member.isPendingInvite;
  }

  Future<void> _confirmRemoveMember(TeamMember member) async {
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
          teamId: _team.id,
          inviteId: member.id,
        );
      } else {
        await teamsApi.removeTeamMember(
          teamId: _team.id,
          memberId: member.id,
        );
      }
      if (!mounted) return;
      await _loadMembers();
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

  Future<void> _openMemberActions(TeamMember member) async {
    if (!_canRemoveMember(member)) return;

    final l10n = context.l10n;
    final isPending = member.isPendingInvite;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  member.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppFontSize.lg,
                    fontWeight: AppFontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _confirmRemoveMember(member);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    isPending
                        ? l10n.teamMembersCancelInvite
                        : l10n.teamMembersRemoveMember,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _continue() async {
    if (_isContinuing) return;
    setState(() => _isContinuing = true);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subscriptionsProvider = context.watch<SubscriptionsProvider>();
    final canManageMembers = _canManageMembers;
    final memberCount = _seats.used;
    final seatProgress = _seats.max <= 0
        ? 0.0
        : (memberCount / _seats.max).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showBackButton) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                  AppSpacing.screenHorizontal,
                  0,
                ),
                child: LinkBackButton(),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.wait([_refreshTeam(), _loadMembers()]);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.md,
                          AppSpacing.screenHorizontal,
                          AppSpacing.md,
                        ),
                        children: [
                          _TeamHeader(
                            team: _team,
                            memberCount: memberCount,
                            showPremiumBadge:
                                subscriptionsProvider.hasActiveSubscription &&
                                    !subscriptionsProvider.hidePremiumUpsells,
                            onPremiumTap: () => openLinkPremiumForTeam(context),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SeatsUsageCard(
                            usedSeats: _seats.used,
                            maxSeats: _seats.max,
                            progress: seatProgress,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            l10n.teamMembersSectionTitle,
                            style: const TextStyle(
                              fontSize: AppFontSize.sm,
                              fontWeight: AppFontWeight.semiBold,
                              color: AppColors.textTertiaire,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          for (var index = 0; index < _members.length; index++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _TeamMemberTile(
                                member: _members[index],
                                avatarColor: _members[index]
                                    .avatarColorForIndex(index),
                                onTap: _canRemoveMember(_members[index])
                                    ? () => _openMemberActions(_members[index])
                                    : null,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          if (canManageMembers)
                            _AddMemberButton(
                              enabled: _hasAvailableSeats,
                              onTap: _openAddMemberSheet,
                            ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: LinkPrimaryButton(
                label: l10n.commonContinue,
                isLoading: _isContinuing,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({
    required this.team,
    required this.memberCount,
    required this.showPremiumBadge,
    required this.onPremiumTap,
  });

  final Team team;
  final int memberCount;
  final bool showPremiumBadge;
  final VoidCallback onPremiumTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brandColor = team.brandColorValue ?? const Color(0xFFE57373);

    return Row(
      children: [
        _TeamLogoAvatar(team: team, fallbackColor: brandColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: TextStyle(
                  fontSize: context.rs(AppFontSize.lg),
                  fontWeight: AppFontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.teamMembersCount(memberCount),
                style: TextStyle(
                  fontSize: context.rs(AppFontSize.sm),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (showPremiumBadge)
          GestureDetector(
            onTap: onPremiumTap,
            child: const _PremiumBadge(),
          ),
      ],
    );
  }
}

class _TeamLogoAvatar extends StatelessWidget {
  const _TeamLogoAvatar({
    required this.team,
    required this.fallbackColor,
  });

  final Team team;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final logoUrl = team.logoImageUrl;
    const size = 64.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fallbackColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: logoUrl != null
          ? Image.network(
              logoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitials(context),
            )
          : _buildInitials(context),
    );
  }

  Widget _buildInitials(BuildContext context) {
    return Text(
      team.initials,
      style: TextStyle(
        color: fallbackColor,
        fontSize: context.rs(18),
        fontWeight: AppFontWeight.bold,
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.or, size: 16),
          const SizedBox(width: 6),
          Text(
            l10n.premiumBadge,
            style: TextStyle(
              color: AppColors.or,
              fontSize: 12,
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatsUsageCard extends StatelessWidget {
  const _SeatsUsageCard({
    required this.usedSeats,
    required this.maxSeats,
    required this.progress,
  });

  final int usedSeats;
  final int maxSeats;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.teamMembersSeatsUsed,
                  style: const TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: AppFontWeight.semiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                maxSeats > 0 ? '$usedSeats / $maxSeats' : '$usedSeats',
                style: const TextStyle(
                  fontSize: AppFontSize.sm,
                  fontWeight: AppFontWeight.semiBold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              color: AppColors.bleu_primaire,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({
    required this.member,
    required this.avatarColor,
    this.onTap,
  });

  final TeamMember member;
  final Color avatarColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = member.status == TeamMemberStatus.active;
    final avatarUrl = ApiConfig.resolvePublicAssetUrl(member.avatarUrl);

    return Material(
      color: AppColors.iconBgMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Text(
                        member.initials,
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: AppFontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontSize: AppFontSize.md,
                        fontWeight: AppFontWeight.semiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.subtitle,
                      style: const TextStyle(
                        fontSize: AppFontSize.sm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _MemberStatusBadge(isActive: isActive),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaire,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberStatusBadge extends StatelessWidget {
  const _MemberStatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.vert_clair : AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isActive ? l10n.teamMembersStatusActive : l10n.teamMembersStatusPending,
        style: TextStyle(
          fontSize: 12,
          fontWeight: AppFontWeight.semiBold,
          color: isActive ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: enabled ? AppColors.border : AppColors.border.withValues(
              alpha: 0.5,
            ),
            radius: AppRadius.lg,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: enabled
                      ? AppColors.bleu_primaire
                      : AppColors.textTertiaire,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.teamMembersAddTitle,
                  style: TextStyle(
                    fontSize: AppFontSize.md,
                    fontWeight: AppFontWeight.semiBold,
                    color: enabled
                        ? AppColors.bleu_primaire
                        : AppColors.textTertiaire,
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

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0.0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
