import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/models/social_link_draft.dart';
import 'package:linkflutter/features/cards/widgets/create_card_header.dart';
import 'package:linkflutter/features/cards/widgets/create_card_step_indicator.dart';
import 'package:linkflutter/features/cards/widgets/social_network_tile.dart';
import 'package:linkflutter/features/subscriptions/widgets/premium_unlock_banner.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class CreateCardStep2Screen extends StatefulWidget {
  const CreateCardStep2Screen({super.key});

  @override
  State<CreateCardStep2Screen> createState() => _CreateCardStep2ScreenState();
}

class _CreateCardStep2ScreenState extends State<CreateCardStep2Screen> {
  final _controllers = <CardSocialPlatform, TextEditingController>{};
  var _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    if (!mounted) return;

    final provider = context.read<CreateCardProvider>();

    if (provider.cardId == null) {
      context.go(RoutePaths.createCard);
      return;
    }

    _resetControllers(provider.socialLinks);
    setState(() => _isReady = true);
  }

  void _resetControllers(List<SocialLinkDraft> links) {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    for (final link in links) {
      _controllers[link.platform] = TextEditingController(text: link.value);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _continue() async {
    final provider = context.read<CreateCardProvider>();
    final subscriptions = context.read<SubscriptionsProvider>();

    for (final entry in _controllers.entries) {
      provider.updateSocialLinkValue(entry.key, entry.value.text.trim());
    }

    final hasFilledLinks = provider.socialLinks.any(
      (link) => link.isSelected && link.value.trim().isNotEmpty,
    );

    if (!subscriptions.hasSocialLinksAccess) {
      if (hasFilledLinks) {
        await openLinkPremium(context);
        return;
      }
      _skip();
      return;
    }

    final success = await provider.saveStep2();
    if (!mounted) return;

    if (success) {
      _goToStep3(provider);
      return;
    }

    final message = provider.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _skip() {
    final provider = context.read<CreateCardProvider>();
    _goToStep3(provider);
  }

  void _goToStep3(CreateCardProvider provider) {
    provider.goToStep(3);
    context.go(RoutePaths.createCardStep3);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = context.l10n;
    final provider = context.watch<CreateCardProvider>();
    final canEditSocial =
        context.watch<SubscriptionsProvider>().hasSocialLinksAccess;
    final isSaving = provider.isSaving;
    final socialLinks = provider.socialLinks;

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
                        currentStep: 2,
                        stepLabel: l10n.createCardStepNetworks,
                      ),
                      SizedBox(
                        height: context.responsive(
                          mobile: AppSpacing.xxl,
                          tablet: AppSpacing.xxxl,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.createCardYourNetworksTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: context.rs(AppFontSize.xl),
                                    fontWeight: AppFontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ),
                          if (!canEditSocial) ...[
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.or_fonce,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 14,
                                    color: AppColors.or,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    l10n.premiumBadge,
                                    style: const TextStyle(
                                      color: AppColors.or,
                                      fontSize: AppFontSize.sm,
                                      fontWeight: AppFontWeight.semiBold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        canEditSocial
                            ? l10n.editCardSocialSubtitle
                            : l10n.premiumSocialSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      if (!canEditSocial)
                        PremiumUnlockBanner(
                          title: l10n.premiumSocialUnlock,
                          onTap: () => openLinkPremium(context),
                        )
                      else
                        ...socialLinks.map((link) {
                          final controller = _controllers[link.platform]!;

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: SocialNetworkTile(
                              draft: link,
                              controller: controller,
                              onToggle: (selected) {
                                provider.toggleSocialLink(
                                  link.platform,
                                  selected,
                                );
                              },
                              onValueChanged: (value) {
                                provider.updateSocialLinkValue(
                                  link.platform,
                                  value,
                                );
                              },
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.lg),
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
                AppSpacing.sm,
              ),
              child: LinkPrimaryButton(
                label: l10n.commonContinue,
                isLoading: isSaving,
                onPressed: isSaving ? null : () => _continue(),
              ),
            ),
            TextButton(
              onPressed: isSaving ? null : _skip,
              child: Text(
                l10n.createCardSkipStep,
                style: const TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: AppFontWeight.medium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
