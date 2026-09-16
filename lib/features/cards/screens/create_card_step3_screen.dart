import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/card_kind_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/auth/models/account_type.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_ready_data.dart';
import 'package:linkflutter/features/cards/widgets/create_card_header.dart';
import 'package:linkflutter/features/cards/widgets/create_card_portfolio_section.dart';
import 'package:linkflutter/features/cards/widgets/create_card_step_indicator.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class CreateCardStep3Screen extends StatefulWidget {
  const CreateCardStep3Screen({super.key});

  @override
  State<CreateCardStep3Screen> createState() => _CreateCardStep3ScreenState();
}

class _CreateCardStep3ScreenState extends State<CreateCardStep3Screen> {
  var _isFinishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<CreateCardProvider>();
      if (provider.cardId == null) {
        context.go(RoutePaths.createCard);
        return;
      }
      await context.read<SubscriptionsProvider>().ensurePaymentConfigLoaded();
    });
  }

  Future<void> _finish() async {
    if (_isFinishing) return;

    final createCard = context.read<CreateCardProvider>();
    final card = createCard.card;
    if (card == null) {
      context.go(RoutePaths.createCard);
      return;
    }

    setState(() => _isFinishing = true);

    final accountType = context.read<AccountTypeProvider>().selectedType;
    final cardKind = accountType == AccountType.team
        ? CardKind.professional
        : CardKind.personal;
    final tagLabel = cardKind.tagLabelL10n(context.l10n);
    final readyData = CardReadyData.fromCreateState(
      card: card,
      draft: createCard.draft,
      tagLabel: tagLabel,
    );

    final cardsProvider = context.read<CardsProvider>();
    cardsProvider.replaceCard(card);
    await persistUserWorkspace(context);
    await cardsProvider.load(force: true);
    if (context.mounted) {
      await persistUserWorkspace(context);
    }
    if (!mounted) return;

    createCard.reset();
    context.go(RoutePaths.createCardSuccess, extra: readyData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: CreateCardHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveLayout(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      CreateCardStepIndicator(
                        currentStep: 3,
                        stepLabel: l10n.createCardStepPortfolio,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const CreateCardPortfolioSection(),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: LinkPrimaryButton(
                label: l10n.commonFinish,
                isLoading: _isFinishing,
                onPressed: _isFinishing ? null : _finish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
