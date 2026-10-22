import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/auth/models/account_type.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/widgets/card_preview.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class CreateCardPromptScreen extends StatelessWidget {
  const CreateCardPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<AuthProvider>().user;
    final accountType = context.watch<AccountTypeProvider>().selectedType;

    final cardKind = accountType == AccountType.team
        ? CardKind.professional
        : CardKind.personal;
    final tagLabel = cardKind.tagLabelL10n(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveLayout(
          alignment: Alignment.center,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user != null)
                          CardPreview(
                            fullName: user.fullName,
                            initials: user.initials,
                            email: user.email,
                            phone: user.phone,
                            tagLabel: tagLabel,
                          )
                        else
                          const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        SizedBox(
                          height: context.responsive(
                            mobile: AppSpacing.xxxl,
                            tablet: 48,
                          ),
                        ),
                        Text(
                          l10n.createCardPromptTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontSize: context.rs(AppFontSize.xl),
                                fontWeight: AppFontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.createCardPromptSubtitle,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LinkPrimaryButton(
                label: l10n.createCardPromptButton,
                onPressed: () {
                  context.read<CreateCardProvider>().initFromUser(
                        context.read<AuthProvider>().user,
                      );
                  context.go(RoutePaths.createCard);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
