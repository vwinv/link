import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/auth/models/account_type.dart';
import 'package:linkflutter/features/auth/widgets/account_type_card.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:linkflutter/shared/widgets/created_by_mega.dart';
import 'package:linkflutter/shared/widgets/link_logo.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  Future<void> _selectType(BuildContext context, AccountType type) async {
    final accountType = context.read<AccountTypeProvider>();
    await accountType.setAuthFlowIntent(type);
    await accountType.complete();
    if (context.mounted) context.push(RoutePaths.register);
  }

  Future<void> _goToLogin(BuildContext context) async {
    await context.read<AccountTypeProvider>().complete();
    if (context.mounted) context.go(RoutePaths.login);
  }

  Future<void> _goToMemberLogin(BuildContext context) async {
    await context.read<AccountTypeProvider>().complete();
    if (!context.mounted) return;
    await context.read<WorkspaceModeProvider>().setMemberLoginIntent(true);
    if (context.mounted) context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.responsive(
                  mobile: AppSpacing.xl,
                  tablet: AppSpacing.xxl,
                ),
              ),
              LinkLogo(
                height: context.responsive(
                  mobile: AppSizes.headerLogoHeight,
                  tablet: AppSizes.headerLogoHeight + 6,
                ),
              ),
              SizedBox(
                height: context.responsive(mobile: AppSpacing.xxxl, tablet: 56),
              ),
              Text(
                l10n.accountTypeTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: context.rs(
                    context.responsive(mobile: AppFontSize.xxl, tablet: 30),
                  ),
                  fontWeight: AppFontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.accountTypeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: context.rs(AppFontSize.lg),
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(
                height: context.responsive(mobile: AppSpacing.xxxl, tablet: 40),
              ),
              AccountTypeCard(
                icon: Icons.person_outline_rounded,
                iconBackgroundColor: AppColors.bleu_clair,
                iconColor: AppColors.bleu_primaire,
                title: l10n.accountTypePersonalTitle,
                description: l10n.accountTypePersonalDescription,
                onTap: () => _selectType(context, AccountType.personal),
              ),
              const SizedBox(height: AppSpacing.xl),
              AccountTypeCard(
                icon: Icons.groups_outlined,
                iconBackgroundColor: AppColors.iconBgMuted,
                iconColor: AppColors.textSecondary,
                title: l10n.accountTypeTeamTitle,
                description: l10n.accountTypeTeamDescription,
                badge: const TeamBadge(),
                onTap: () => _selectType(context, AccountType.team),
              ),
              const Spacer(),
              LinkPrimaryButton(
                label: l10n.accountTypeMemberLogin,
                onPressed: () => _goToMemberLogin(context),
                borderRadius: AppRadius.lg,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.commonAlreadyAccount,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(AppFontSize.lg),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _goToLogin(context),
                      child: Text(
                        l10n.authSignIn,
                        style: TextStyle(
                          color: AppColors.bleu_primaire,
                          fontSize: context.rs(AppFontSize.lg),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const CreatedByMega(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
