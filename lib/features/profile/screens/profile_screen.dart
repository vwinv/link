import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/auth/models/user.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/locale_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/notifications_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/features/notifications/services/push_notifications_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _teamMemberCount;
  var _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _loadTeamMemberCount(),
      context.read<SubscriptionsProvider>().refresh(),
    ]);
  }

  Future<void> _loadTeamMemberCount() async {
    final team = context.read<TeamsProvider>().myTeam;
    if (team == null) return;

    try {
      final result =
          await context.read<TeamsApiService>().fetchTeamMembers(team.id);
      if (!mounted) return;
      setState(() => _teamMemberCount = result.seats.used);
    } catch (_) {
      // Ignore: subtitle without count.
    }
  }

  Future<void> _setLanguage(AppLanguage language) {
    return context.read<LocaleProvider>().setLanguage(language);
  }

  Future<void> _logout() async {
    final push = context.read<PushNotificationsService>();
    try {
      await push.stop();
    } catch (_) {}
    if (!mounted) return;
    resetUserWorkspace(context);
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.profileDeleteAccountTitle),
        content: Text(context.l10n.profileDeleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      resetUserWorkspace(context);
      await context.read<AuthProvider>().deleteAccount();
      if (!mounted) return;
      context.go(RoutePaths.login);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.profileDeleteAccountError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthProvider>().user;
    final team = context.watch<TeamsProvider>().myTeam;
    final cards = context.watch<CardsProvider>().cards;
    final hasPremium =
        context.watch<SubscriptionsProvider>().hasActiveSubscription;
    final language = context.watch<LocaleProvider>().language;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
          ),
          children: [
            Text(
              l10n.profileTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(28),
                fontWeight: AppFontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (user != null) ...[
              _ProfileUserCard(
                user: user,
                avatarImageUrl:
                    context.watch<CardsProvider>().primaryCard?.avatarImageUrl,
                onEdit: () => openEditCardInfo(context),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (!hasPremium) ...[
              _PremiumUpgradeBanner(
                onTap: () => openLinkPremium(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ] else
              const SizedBox(height: AppSpacing.md),
            _SectionLabel(l10n.profileSectionAccount),
            const SizedBox(height: AppSpacing.md),
            _ProfileMenuTile(
              icon: Icons.groups_outlined,
              title: l10n.profileTeamSpace,
              subtitle: _teamSubtitle(context, team),
              onTap: () => _openTeamSpace(context, team),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.profileManageWallet,
              onTap: () => _openWallet(context, cards),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.notifications_outlined,
              title: l10n.profileNotifications,
              badgeCount: context.watch<NotificationsProvider>().unreadCount,
              onTap: () => context.push(RoutePaths.notifications),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.credit_card_outlined,
              title: l10n.profileMyCards,
              subtitle: l10n.profileCardsCount(cards.length),
              onTap: () => _openMyCards(context, cards),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SectionLabel(l10n.profileSectionSettings),
            const SizedBox(height: AppSpacing.md),
            _LanguageMenuTile(
              language: language,
              onChanged: _setLanguage,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.lock_outline_rounded,
              title: l10n.profilePrivacy,
              onTap: () => openPrivacyPolicy(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.close_rounded,
              title: l10n.profileLogout,
              isDestructive: true,
              showChevron: false,
              onTap: _isDeletingAccount ? () {} : _logout,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProfileMenuTile(
              icon: Icons.delete_outline_rounded,
              title: l10n.profileDeleteAccount,
              isDestructive: true,
              showChevron: false,
              onTap: _isDeletingAccount ? () {} : _confirmDeleteAccount,
            ),
            if (_isDeletingAccount) ...[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  String? _teamSubtitle(BuildContext context, Team? team) {
    final l10n = context.l10n;
    if (team == null) return l10n.profileTeamConfigure;
    final count = _teamMemberCount;
    if (count == null) return team.name;
    return l10n.profileTeamMembers(team.name, count);
  }

  Future<void> _openTeamSpace(BuildContext context, Team? team) async {
    final teams = context.read<TeamsProvider>();

    // Membre invité (pas owner) → espace membre, pas la gestion owner / Premium.
    if (teams.canAccessMemberSpace && teams.ownedTeam == null) {
      await enterMemberWorkspace(context);
      return;
    }

    final hasTeamSubscription = await ensureTeamSubscription(context);
    if (!hasTeamSubscription || !mounted) return;

    final owned = teams.ownedTeam ?? team;
    if (owned == null) {
      await openSetupTeam(context);
      if (!mounted) return;
      await _loadTeamMemberCount();
      return;
    }

    await openTeamMembers(context, team: owned);
    if (!mounted) return;
    await _loadTeamMemberCount();
  }

  Future<void> _openMyCards(
    BuildContext context,
    List<BusinessCard> cards,
  ) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileCreateCardFirst)),
      );
      return;
    }

    final card = cards.length == 1
        ? cards.first
        : await _pickCard(context, cards);

    if (card == null || !context.mounted) return;
    openMyCardScreen(context, card);
  }

  Future<void> _openWallet(BuildContext context, List<BusinessCard> cards) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileCreateCardForWallet)),
      );
      return;
    }

    final card = cards.length == 1
        ? cards.first
        : await _pickCard(context, cards);

    if (card == null || !context.mounted) return;
    openWalletScreen(context, card);
  }

  Future<BusinessCard?> _pickCard(
    BuildContext context,
    List<BusinessCard> cards,
  ) {
    return showModalBottomSheet<BusinessCard>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.pickCardTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(AppFontSize.lg),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...cards.map(
                  (card) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _ProfileAvatar(
                      initials: card.initials,
                      imageUrl: card.avatarImageUrl,
                      radius: 20,
                    ),
                    title: Text(
                      card.fullName,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      card.kind.tagLabelL10n(l10n),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(card),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textTertiaire,
        fontSize: context.rs(12),
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ProfileUserCard extends StatelessWidget {
  const _ProfileUserCard({
    required this.user,
    required this.onEdit,
    this.avatarImageUrl,
  });

  final User user;
  final VoidCallback onEdit;
  final String? avatarImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          _ProfileAvatar(
            initials: user.initials,
            imageUrl: avatarImageUrl,
            radius: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.rs(AppFontSize.md),
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.rs(AppFontSize.sm),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.bleu_primaire,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.l10n.profileEdit,
              style: TextStyle(
                color: AppColors.bleu_primaire,
                fontSize: context.rs(AppFontSize.sm),
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.initials,
    this.imageUrl,
    this.radius = 28,
  });

  final String initials;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final size = radius * 2;

    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsCircle(),
        ),
      );
    }

    return _initialsCircle();
  }

  Widget _initialsCircle() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.bleu_primaire,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.onPrimary,
          fontWeight: AppFontWeight.bold,
          fontSize: radius >= 24 ? AppFontSize.md : AppFontSize.sm,
        ),
      ),
    );
  }
}

class _PremiumUpgradeBanner extends StatelessWidget {
  const _PremiumUpgradeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151518),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0xFF2A2A2E)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.or,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.or_fonce,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profilePremiumTitle,
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.profilePremiumSubtitle,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.45),
                        fontSize: context.rs(AppFontSize.sm),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.or.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badgeCount = 0,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int badgeCount;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor =
        isDestructive ? AppColors.error : AppColors.textSecondary;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.rouge_clair
                      : AppColors.iconBgMutedDark,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeCount > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.or,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: AppColors.or_fonce,
                      fontSize: 11,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (showChevron)
                Icon(
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

class _LanguageMenuTile extends StatelessWidget {
  const _LanguageMenuTile({
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.iconBgMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bleu_turquoise_clair,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: AppColors.bleu_turquoise,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.profileLanguage,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(AppFontSize.md),
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ),
          _LanguageToggle(
            language: language,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.textPrimary, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageChip(
            label: 'FR',
            isSelected: language == AppLanguage.fr,
            onTap: () => onChanged(AppLanguage.fr),
          ),
          _LanguageChip(
            label: 'EN',
            isSelected: language == AppLanguage.en,
            onTap: () => onChanged(AppLanguage.en),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
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
      color: isSelected ? AppColors.bleu_primaire : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          width: 36,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            color: isSelected ? AppColors.bleu_primaire : AppColors.surface,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              fontSize: context.rs(12),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
