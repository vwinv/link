import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/config/payments_config.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/l10n/app_localizations.dart';
import 'package:linkflutter/features/subscriptions/models/payment_config.dart';
import 'package:linkflutter/features/subscriptions/models/offer_entitlements.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer_price.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPremiumScreen extends StatefulWidget {
  const LinkPremiumScreen({
    super.key,
    this.preferredAudience,
  });

  /// Pré-sélectionne l’offre correspondante sans masquer les autres.
  final OfferAudience? preferredAudience;

  @override
  State<LinkPremiumScreen> createState() => _LinkPremiumScreenState();
}

class _LinkPremiumScreenState extends State<LinkPremiumScreen> {
  List<PremiumOffer> _offers = [];
  String? _selectedOfferId;
  String? _selectedPriceId;
  bool _isLoading = true;
  bool _isSubscribing = false;
  bool _loadFailed = false;
  bool _useStripeCheckout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOffers());
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final api = context.read<SubscriptionsApiService>();
      final results = await Future.wait([
        api.fetchOffers(),
        api.fetchPaymentConfig(),
      ]);
      if (!mounted) return;

      final allOffers = results[0] as List<PremiumOffer>;
      final paymentConfig = results[1] as PaymentConfig;
      final paymentsEnabled = paymentConfig.paymentsEnabled;

      final offers = allOffers;

      PremiumOffer? selectedOffer;
      final preferred = widget.preferredAudience;
      if (preferred != null) {
        for (final offer in offers) {
          if (offer.audience == preferred) {
            selectedOffer = offer;
            break;
          }
        }
      }
      if (selectedOffer == null) {
        for (final offer in offers) {
          if (offer.popularPrice != null) {
            selectedOffer = offer;
            break;
          }
        }
      }
      selectedOffer ??= offers.isNotEmpty ? offers.first : null;

      setState(() {
        _offers = offers;
        _selectedOfferId = selectedOffer?.id;
        _selectedPriceId = selectedOffer?.popularPrice?.id;
        _useStripeCheckout = PaymentsConfig.useStripeCheckout(paymentsEnabled);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  PremiumOffer? get _selectedOffer {
    if (_selectedOfferId == null) return null;
    for (final offer in _offers) {
      if (offer.id == _selectedOfferId) return offer;
    }
    return null;
  }

  PremiumOfferPrice? get _selectedPrice {
    final offer = _selectedOffer;
    if (offer == null || _selectedPriceId == null) return null;
    for (final price in offer.prices) {
      if (price.id == _selectedPriceId) return price;
    }
    return null;
  }

  Future<void> _startPremium() async {
    final selectedOffer = _selectedOffer;
    final selectedPrice = _selectedPrice;
    if (selectedOffer == null || selectedPrice == null || _isSubscribing) return;

    final messenger = ScaffoldMessenger.of(context);
    final teamId = selectedOffer.audience.isTeam
        ? context.read<TeamsProvider>().myTeam?.id
        : null;

    setState(() => _isSubscribing = true);

    try {
      if (_useStripeCheckout) {
        final session = await context
            .read<SubscriptionsApiService>()
            .createCheckoutSession(
              offerSlug: selectedOffer.slug,
              billingType: selectedPrice.billingType,
              teamId: teamId,
            );
        if (!mounted) return;

        final checkoutUri = Uri.parse(session.checkoutUrl);
        final launched = await launchUrl(
          checkoutUri,
          mode: LaunchMode.externalApplication,
        );
        if (!mounted) return;

        if (!launched) {
          messenger.showSnackBar(
            SnackBar(content: Text(context.l10n.premiumCheckoutLaunchError)),
          );
          return;
        }

        context.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.premiumCheckoutRedirect)),
        );
        return;
      }

      final subscription =
          await context.read<SubscriptionsApiService>().subscribe(
                offerSlug: selectedOffer.slug,
                billingType: selectedPrice.billingType,
                teamId: teamId,
              );
      if (!mounted) return;

      context.read<SubscriptionsProvider>().setSubscription(subscription);
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.premiumActivated(
              selectedOffer.title,
              selectedPrice.title,
            ),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.premiumSubscribeError)),
      );
    } finally {
      if (mounted) setState(() => _isSubscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _CloseButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.or),
                    )
                  : _loadFailed
                      ? _ErrorState(onRetry: _loadOffers)
                          : _offers.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.screenHorizontal,
                                    ),
                                    child: const _EmptyOffersState(),
                                  ),
                                )
                          : _HorizontalOfferPackagesCarousel(
                              offers: _offers,
                              selectedOfferId: _selectedOfferId,
                              selectedPriceId: _selectedPriceId,
                              onOfferChanged: (offer) {
                                final price = offer.popularPrice ??
                                    (offer.prices.isNotEmpty
                                        ? offer.prices.first
                                        : null);
                                setState(() {
                                  _selectedOfferId = offer.id;
                                  _selectedPriceId = price?.id;
                                });
                              },
                              onPriceSelected: (offer, price) {
                                setState(() {
                                  _selectedOfferId = offer.id;
                                  _selectedPriceId = price.id;
                                });
                              },
                            ),
            ),
            if (!_isLoading &&
                !_loadFailed &&
                _offers.isNotEmpty &&
                _selectedPrice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: FilledButton(
                        onPressed: _selectedPriceId == null || _isSubscribing
                            ? null
                            : _startPremium,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.or,
                          foregroundColor: AppColors.or_fonce,
                          disabledBackgroundColor:
                              AppColors.or.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: _isSubscribing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.or_fonce,
                                ),
                              )
                            : Text(
                                _useStripeCheckout
                                    ? l10n.premiumProceedToPayment
                                    : l10n.premiumStart,
                                style: const TextStyle(
                                  fontSize: AppFontSize.md,
                                  fontWeight: AppFontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.premiumRenewalNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.45),
                        fontSize: context.rs(12),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PremiumCrownIcon extends StatelessWidget {
  const _PremiumCrownIcon();

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.or,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.workspace_premium_rounded,
        color: AppColors.or_fonce,
        size: size * 0.5,
      ),
    );
  }
}

class _HorizontalOfferPackagesCarousel extends StatefulWidget {
  const _HorizontalOfferPackagesCarousel({
    required this.offers,
    required this.selectedOfferId,
    required this.selectedPriceId,
    required this.onOfferChanged,
    required this.onPriceSelected,
  });

  final List<PremiumOffer> offers;
  final String? selectedOfferId;
  final String? selectedPriceId;
  final ValueChanged<PremiumOffer> onOfferChanged;
  final void Function(PremiumOffer offer, PremiumOfferPrice price)
      onPriceSelected;

  @override
  State<_HorizontalOfferPackagesCarousel> createState() =>
      _HorizontalOfferPackagesCarouselState();
}

class _HorizontalOfferPackagesCarouselState
    extends State<_HorizontalOfferPackagesCarousel> {
  static const _viewportFraction = 0.82;

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.offers.indexWhere(
      (offer) => offer.id == widget.selectedOfferId,
    );
    _currentPage = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              clipBehavior: Clip.hardEdge,
              itemCount: widget.offers.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                widget.onOfferChanged(widget.offers[index]);
              },
              itemBuilder: (context, index) {
                final offer = widget.offers[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: _OfferPackageCard(
                    offer: offer,
                    isOfferSelected: offer.id == widget.selectedOfferId,
                    selectedPriceId: widget.selectedPriceId,
                    onPriceSelected: (price) =>
                        widget.onPriceSelected(offer, price),
                  ),
                );
              },
            ),
          ),
          if (widget.offers.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            _OfferPageIndicator(
              count: widget.offers.length,
              currentIndex: _currentPage,
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferPageIndicator extends StatelessWidget {
  const _OfferPageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.or
                : AppColors.onPrimary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}

class _OfferPackageCard extends StatelessWidget {
  const _OfferPackageCard({
    required this.offer,
    required this.isOfferSelected,
    required this.selectedPriceId,
    required this.onPriceSelected,
  });

  final PremiumOffer offer;
  final bool isOfferSelected;
  final String? selectedPriceId;
  final ValueChanged<PremiumOfferPrice> onPriceSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isOfferSelected ? AppColors.onPrimary : const Color(0xFF2A2A2E),
          width: isOfferSelected ? 2 : 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: _PremiumCrownIcon()),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    offer.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: context.rs(AppFontSize.lg),
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  if (offer.subtitle != null && offer.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      offer.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.65),
                        fontSize: context.rs(AppFontSize.sm),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _OfferDetailRow(
                    icon: Icons.category_outlined,
                    label: l10n.premiumFeatureType,
                    value: _audienceLabel(l10n, offer.audience),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.document_scanner_outlined,
                    label: l10n.premiumFeatureScans,
                    value: _scansLabel(l10n, offer.maxAiScans),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.groups_outlined,
                    label: l10n.premiumFeatureUsers,
                    value: _usersLabel(l10n, offer),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.brush_outlined,
                    label: l10n.premiumFeatureCustomization,
                    value: offer.canCustomize
                        ? l10n.commonIncludedFeminine
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.premiumFeatureWallet,
                    value: offer.hasWallet
                        ? l10n.commonIncluded
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.bar_chart_outlined,
                    label: l10n.premiumFeatureAnalytics,
                    value: offer.hasAnalytics
                        ? l10n.commonIncludedFeminine
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.people_outline,
                    label: l10n.premiumFeatureVisitors,
                    value: offer.hasVisitorInsights
                        ? l10n.commonIncluded
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.share_outlined,
                    label: l10n.premiumFeatureSocial,
                    value: offer.hasSocialLinks
                        ? l10n.commonIncluded
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _OfferDetailRow(
                    icon: Icons.badge_outlined,
                    label: l10n.premiumFeaturePortfolio,
                    value: offer.hasPortfolio
                        ? l10n.commonIncluded
                        : l10n.commonNotIncluded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (offer.prices.isEmpty)
                    Text(
                      l10n.premiumNoPricing,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.45),
                        fontSize: context.rs(AppFontSize.sm),
                      ),
                    )
                  else
                    for (var index = 0; index < offer.prices.length; index++) ...[
                      if (index > 0) const SizedBox(height: AppSpacing.sm),
                      _PremiumPriceRow(
                        price: offer.prices[index],
                        isSelected: isOfferSelected &&
                            offer.prices[index].id == selectedPriceId,
                        onTap: () => onPriceSelected(offer.prices[index]),
                      ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _audienceLabel(AppLocalizations l10n, OfferAudience audience) {
    return audience.isTeam
        ? l10n.premiumAudienceTeam
        : l10n.premiumAudiencePersonal;
  }

  static String _scansLabel(AppLocalizations l10n, int maxAiScans) {
    if (maxAiScans < 0) return l10n.commonUnlimited;
    if (maxAiScans == 0) return l10n.commonNotIncluded;
    return l10n.premiumScansPerPeriod(maxAiScans);
  }

  static String _usersLabel(AppLocalizations l10n, PremiumOffer offer) {
    if (offer.audience.isTeam) {
      if (offer.maxTeamMembers < 0) return l10n.commonUnlimited;
      return l10n.premiumTeamMembers(offer.maxTeamMembers);
    }
    return l10n.premiumOneUser;
  }
}

class _OfferDetailRow extends StatelessWidget {
  const _OfferDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.onPrimary.withValues(alpha: 0.45),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label · ',
          style: TextStyle(
            color: AppColors.onPrimary.withValues(alpha: 0.45),
            fontSize: context.rs(12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.onPrimary.withValues(alpha: 0.88),
              fontSize: context.rs(12),
              fontWeight: AppFontWeight.medium,
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumPriceRow extends StatelessWidget {
  const _PremiumPriceRow({
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  final PremiumOfferPrice price;
  final bool isSelected;
  final VoidCallback onTap;

  String get _detailLine {
    if (price.priceLabel != null && price.priceLabel!.isNotEmpty) {
      return price.displayPrice;
    }
    if (price.subtitle != null && price.subtitle!.isNotEmpty) {
      return price.subtitle!;
    }
    return price.displayPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151518),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.or : const Color(0xFF3A3A40),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          price.title,
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: context.rs(AppFontSize.lg),
                            fontWeight: AppFontWeight.bold,
                          ),
                        ),
                        if (price.badgeLabel != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.or,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              price.badgeLabel!,
                              style: const TextStyle(
                                color: AppColors.or_fonce,
                                fontSize: 11,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _detailLine,
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.5),
                        fontSize: context.rs(AppFontSize.sm),
                      ),
                    ),
                  ],
                ),
              ),
              if (price.discountPercent != null) ...[
                Text(
                  '-${price.discountPercent}%',
                  style: const TextStyle(
                    color: AppColors.or,
                    fontSize: AppFontSize.sm,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              _PriceSelectionIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceSelectionIndicator extends StatelessWidget {
  const _PriceSelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.or : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.or : const Color(0xFF3A3A40),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.or_fonce,
            )
          : null,
    );
  }
}

class _EmptyOffersState extends StatelessWidget {
  const _EmptyOffersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF2A2A2E)),
      ),
      child: Text(
        context.l10n.premiumNoOffers,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.onPrimary.withValues(alpha: 0.65),
          fontSize: context.rs(AppFontSize.md),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.premiumLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onPrimary.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onRetry,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
