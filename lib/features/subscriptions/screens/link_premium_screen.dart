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
import 'package:linkflutter/features/subscriptions/widgets/payment_billing_picker_sheet.dart';
import 'package:linkflutter/features/subscriptions/widgets/soft_pay_sheet.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:provider/provider.dart';

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
  final Map<String, String> _priceByOfferId = {};
  bool _isLoading = true;
  bool _isSubscribing = false;
  bool _loadFailed = false;
  bool _usePaydunyaSoftPay = false;
  bool _hideInAppPayments = false;

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
      final initialPrice = selectedOffer?.preferredPrice;

      setState(() {
        _offers = offers;
        _priceByOfferId
          ..clear()
          ..addEntries(
            offers
                .where((offer) => offer.preferredPrice != null)
                .map(
                  (offer) => MapEntry(offer.id, offer.preferredPrice!.id),
                ),
          );
        _selectedOfferId = selectedOffer?.id;
        _selectedPriceId = initialPrice?.id;
        _hideInAppPayments = paymentConfig.hideInAppPayments;
        _usePaydunyaSoftPay = PaymentsConfig.usePaydunyaSoftPay(
          apiPaymentsEnabled: paymentsEnabled,
          hideInAppPayments: paymentConfig.hideInAppPayments,
        );
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

  PremiumOfferPrice? _priceForOffer(PremiumOffer offer) {
    final rememberedId = _priceByOfferId[offer.id];
    if (rememberedId != null) {
      for (final price in offer.prices) {
        if (price.id == rememberedId) return price;
      }
    }
    return offer.preferredPrice ??
        (offer.prices.isNotEmpty ? offer.prices.first : null);
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
    final seats = selectedOffer.hasPerSeatPricing && selectedPrice.isPerSeat
        ? selectedOffer.minSeats
        : null;

    if (_hideInAppPayments) {
      setState(() => _isSubscribing = true);
      try {
        await _submitSignupRequest(
          offer: selectedOffer,
          billingType: selectedPrice.billingType,
          teamId: teamId,
          seats: seats,
        );
      } on ApiException catch (error) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(error.message)));
      } catch (_) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.premiumSubscribeError)),
        );
      } finally {
        if (mounted) setState(() => _isSubscribing = false);
      }
      return;
    }

    final billingChoices = PaymentBillingChoice.forOffer(
      offer: selectedOffer,
      selectedPrice: selectedPrice,
      seats: seats ?? selectedOffer.minSeats,
    );
    final billingChoice = await PaymentBillingPickerSheet.show(
      context: context,
      offerTitle: selectedOffer.title,
      choices: billingChoices,
    );
    if (!mounted || billingChoice == null) return;

    setState(() => _isSubscribing = true);

    try {
      final checkoutPrice = billingChoice.sourcePrice;
      final billingType = billingChoice.billingType;
      final seatCount = seats ?? selectedOffer.minSeats;
      final baseAmount = checkoutPrice.totalForSeats(
        seatCount,
        includedSeats: selectedOffer.minSeats,
      );
      final amount = billingType.toUpperCase() == 'YEARLY' &&
              checkoutPrice.billingType.toUpperCase() == 'MONTHLY'
          ? baseAmount * 12
          : baseAmount;
      final isFree = amount <= 0;
      final montantLabel = billingChoice.amountLabel;

      // Offre payante → bottom sheet SoftPay (Wave / OM / Free)
      if (!isFree) {
        final api = context.read<SubscriptionsApiService>();
        final auth = context.read<AuthProvider>();
        final user = auth.user;

        String? invoiceToken;
        if (_usePaydunyaSoftPay) {
          final session = await api.createCheckoutSession(
            offerSlug: selectedOffer.slug,
            billingType: billingType,
            teamId: teamId,
            seats: seats,
          );
          if (!mounted) return;
          invoiceToken = session.invoiceToken;
        }

        if (!mounted) return;
        final paid = await SoftPaySheet.show(
          context,
          offerSlug: selectedOffer.slug,
          billingType: billingType,
          montantLabel: montantLabel,
          api: api,
          initialPrenom: user?.firstName ?? '',
          initialNom: user?.lastName ?? '',
          initialTelephone: user?.phone ?? '',
          email: user?.email,
          teamId: teamId,
          seats: seats,
          invoiceToken: invoiceToken,
        );
        if (!mounted) return;

        if (paid == true) {
          await context.read<SubscriptionsProvider>().refresh();
          if (!mounted) return;
          context.pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.premiumActivated(
                  selectedOffer.title,
                  billingChoice.title,
                ),
              ),
            ),
          );
        }
        return;
      }

      final subscription =
          await context.read<SubscriptionsApiService>().subscribe(
                offerSlug: selectedOffer.slug,
                billingType: billingType,
                teamId: teamId,
                seats: seats,
              );
      if (!mounted) return;

      context.read<SubscriptionsProvider>().setSubscription(subscription);
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.premiumActivated(
              selectedOffer.title,
              billingChoice.title,
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

  Future<void> _submitSignupRequest({
    required PremiumOffer offer,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    final api = context.read<SubscriptionsApiService>();
    final auth = context.read<AuthProvider>();
    final result = await api.createSignupRequest(
      offerSlug: offer.slug,
      billingType: billingType,
      teamId: teamId,
      seats: seats,
    );
    if (!mounted) return;

    final name = result.firstName.trim().isNotEmpty
        ? result.firstName.trim()
        : (auth.user?.firstName.trim() ?? '');
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) => _SignupThanksDialog(
        title: name.isEmpty
            ? ctx.l10n.premiumSignupThanksTitleAnonymous
            : ctx.l10n.premiumSignupThanksTitle(name),
        message: ctx.l10n.premiumSignupThanks,
      ),
    );
    if (!mounted) return;
    context.pop();
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
                                final selected = _priceForOffer(offer);
                                setState(() {
                                  _selectedOfferId = offer.id;
                                  _selectedPriceId = selected?.id;
                                  if (selected != null) {
                                    _priceByOfferId[offer.id] = selected.id;
                                  }
                                });
                              },
                              onPriceSelected: (offer, price) {
                                setState(() {
                                  _selectedOfferId = offer.id;
                                  _selectedPriceId = price.id;
                                  _priceByOfferId[offer.id] = price.id;
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
                                _hideInAppPayments
                                    ? l10n.premiumSignUp
                                    : _usePaydunyaSoftPay
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
                      _hideInAppPayments
                          ? l10n.premiumSignupNote
                          : l10n.premiumRenewalNote,
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

class _SignupThanksDialog extends StatelessWidget {
  const _SignupThanksDialog({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: const Color(0xFF151518),
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: Color(0xFF2A2A2E)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PremiumCrownIcon(),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontSize: AppFontSize.xl,
                fontWeight: AppFontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onPrimary.withValues(alpha: 0.55),
                fontSize: AppFontSize.sm,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.or,
                  foregroundColor: AppColors.or_fonce,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  l10n.premiumSignupOk,
                  style: const TextStyle(
                    fontSize: AppFontSize.md,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
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
    final orderedPrices = offer.pricesYearlyFirst;

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
                    for (var index = 0; index < orderedPrices.length; index++) ...[
                      if (index > 0) const SizedBox(height: AppSpacing.sm),
                      _PremiumPriceRow(
                        price: orderedPrices[index],
                        includedSeats: offer.minSeats,
                        isSelected: isOfferSelected &&
                            orderedPrices[index].id == selectedPriceId,
                        onTap: () => onPriceSelected(orderedPrices[index]),
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
      if (offer.hasPerSeatPricing) {
        if (offer.maxTeamMembers < 0) {
          return l10n.premiumSeatsFrom(offer.minSeats);
        }
        return l10n.premiumSeatsRange(offer.minSeats, offer.maxTeamMembers);
      }
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
          '$label - ',
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
    this.includedSeats = 1,
  });

  final PremiumOfferPrice price;
  final bool isSelected;
  final VoidCallback onTap;
  final int includedSeats;

  String get _amountLabel {
    if (price.isPerSeat) {
      return price.displayTotal(includedSeats, includedSeats: includedSeats);
    }
    return '${PremiumOfferPrice.formatAmount(price.priceAmount)} ${price.currency}';
  }

  String? get _extraLine {
    if (!price.isPerSeat) return price.subtitle;
    final parts = <String>[
      if (price.subtitle != null && price.subtitle!.isNotEmpty) price.subtitle!,
      '$includedSeats inclus',
      price.extraSeatLabel(),
    ];
    return parts.join(' - ');
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
                        Flexible(
                          child: Text(
                            price.title,
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: context.rs(AppFontSize.lg),
                              fontWeight: AppFontWeight.bold,
                            ),
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
                    const SizedBox(height: 6),
                    Text(
                      _amountLabel,
                      style: TextStyle(
                        color: AppColors.or,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    if (_extraLine != null && _extraLine!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _extraLine!,
                        style: TextStyle(
                          color: AppColors.onPrimary.withValues(alpha: 0.5),
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ],
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
