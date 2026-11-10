import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/points/services/points_api_service.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer_price.dart';
import 'package:provider/provider.dart';

/// Choix de facturation avant paiement : annuel proposé en premier (mensuel × 12).
class PaymentBillingChoice {
  const PaymentBillingChoice({
    required this.billingType,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.sourcePrice,
    required this.amountFcfa,
    this.isRecommended = false,
    this.payWithPoints = false,
    this.enabled = true,
    this.pointsRequired,
    this.pointsBalance,
  });

  final String billingType;
  final String title;
  final String subtitle;
  final String amountLabel;
  final PremiumOfferPrice sourcePrice;
  final double amountFcfa;
  final bool isRecommended;
  final bool payWithPoints;
  final bool enabled;
  final double? pointsRequired;
  final double? pointsBalance;

  static List<PaymentBillingChoice> forOffer({
    required PremiumOffer offer,
    required PremiumOfferPrice selectedPrice,
    required int seats,
  }) {
    final monthly =
        offer.monthlyPrice ??
        (selectedPrice.billingType.toUpperCase() == 'MONTHLY'
            ? selectedPrice
            : null);
    final choices = <PaymentBillingChoice>[];
    final included = offer.includedSeats;

    // Annuel = mensuel × 12 (proposé en premier, non obligatoire).
    if (monthly != null) {
      final monthlyAmount = monthly.totalForSeats(
        seats,
        includedSeats: included,
      );
      final annualAmount = monthlyAmount * 12;
      choices.add(
        PaymentBillingChoice(
          billingType: 'YEARLY',
          title: 'Annuel',
          subtitle: '12 × mensuel',
          amountLabel:
              '${PremiumOfferPrice.formatAmount(annualAmount)} ${monthly.currency}',
          sourcePrice: monthly,
          amountFcfa: annualAmount,
          isRecommended: true,
        ),
      );
      choices.add(
        PaymentBillingChoice(
          billingType: 'MONTHLY',
          title: 'Mensuel',
          subtitle: 'par mois',
          amountLabel: _amountLabel(monthly, seats, included),
          sourcePrice: monthly,
          amountFcfa: monthlyAmount,
        ),
      );
    }

    final selectedType = selectedPrice.billingType.toUpperCase();
    if (selectedType != 'MONTHLY' &&
        selectedType != 'YEARLY' &&
        choices.every((c) => c.sourcePrice.id != selectedPrice.id)) {
      final amount = selectedPrice.totalForSeats(
        seats,
        includedSeats: included,
      );
      choices.add(
        PaymentBillingChoice(
          billingType: selectedPrice.billingType,
          title: selectedPrice.title,
          subtitle: selectedPrice.subtitle ?? '',
          amountLabel: _amountLabel(selectedPrice, seats, included),
          sourcePrice: selectedPrice,
          amountFcfa: amount,
        ),
      );
    }

    if (choices.isEmpty) {
      final amount = selectedPrice.totalForSeats(
        seats,
        includedSeats: included,
      );
      choices.add(
        PaymentBillingChoice(
          billingType: selectedPrice.billingType,
          title: selectedPrice.title,
          subtitle: selectedPrice.subtitle ?? '',
          amountLabel: _amountLabel(selectedPrice, seats, included),
          sourcePrice: selectedPrice,
          amountFcfa: amount,
          isRecommended: true,
        ),
      );
    }

    return choices;
  }

  /// 1 point = 10 FCFA.
  static double pointsForFcfa(double amountFcfa) =>
      (amountFcfa / 10).ceilToDouble();

  static String _amountLabel(
    PremiumOfferPrice price,
    int seats,
    int includedSeats,
  ) {
    if (price.isPerSeat) {
      return price.displayTotal(seats, includedSeats: includedSeats);
    }
    return price.displayPrice;
  }
}

class PaymentBillingPickerSheet extends StatefulWidget {
  const PaymentBillingPickerSheet({
    super.key,
    required this.offerTitle,
    required this.choices,
  });

  final String offerTitle;
  final List<PaymentBillingChoice> choices;

  static Future<PaymentBillingChoice?> show({
    required BuildContext context,
    required String offerTitle,
    required List<PaymentBillingChoice> choices,
  }) async {
    if (choices.isEmpty) return null;

    final withPoints = await _withDropPointsOption(context, choices);
    if (withPoints.length == 1 && !withPoints.first.payWithPoints) {
      return withPoints.first;
    }

    if (!context.mounted) return null;
    return showModalBottomSheet<PaymentBillingChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBillingPickerSheet(
        offerTitle: offerTitle,
        choices: withPoints,
      ),
    );
  }

  static Future<List<PaymentBillingChoice>> _withDropPointsOption(
    BuildContext context,
    List<PaymentBillingChoice> base,
  ) async {
    final periodChoices = base
        .where((c) => !c.payWithPoints)
        .toList(growable: false);
    if (periodChoices.isEmpty) return base;

    double? balance;
    try {
      final overview = await context.read<PointsApiService>().fetchOverview();
      balance = overview.balancePoints;
    } catch (_) {
      balance = null;
    }

    PaymentBillingChoice? yearly;
    PaymentBillingChoice? monthly;
    for (final choice in periodChoices) {
      final type = choice.billingType.toUpperCase();
      if (type == 'YEARLY') yearly = choice;
      if (type == 'MONTHLY') monthly = choice;
    }

    final bal = balance ?? 0;
    final yearlyPts = yearly != null
        ? PaymentBillingChoice.pointsForFcfa(yearly.amountFcfa)
        : null;
    final monthlyPts = monthly != null
        ? PaymentBillingChoice.pointsForFcfa(monthly.amountFcfa)
        : null;

    late final PaymentBillingChoice target;
    late final double pointsRequired;
    if (yearly != null && yearlyPts != null && bal >= yearlyPts) {
      target = yearly;
      pointsRequired = yearlyPts;
    } else if (monthly != null && monthlyPts != null && bal >= monthlyPts) {
      target = monthly;
      pointsRequired = monthlyPts;
    } else if (yearly != null && yearlyPts != null) {
      target = yearly;
      pointsRequired = yearlyPts;
    } else if (monthly != null && monthlyPts != null) {
      target = monthly;
      pointsRequired = monthlyPts;
    } else {
      target = periodChoices.first;
      pointsRequired = PaymentBillingChoice.pointsForFcfa(target.amountFcfa);
    }

    final enabled = balance != null && balance >= pointsRequired;
    final pointsLabel = pointsRequired == pointsRequired.roundToDouble()
        ? '${pointsRequired.toInt()} pts'
        : '$pointsRequired pts';

    return [
      ...periodChoices,
      PaymentBillingChoice(
        billingType: target.billingType,
        title: 'Drop-Points',
        subtitle: balance == null
            ? 'Solde indisponible'
            : enabled
            ? 'Payer avec vos points · ${target.title.toLowerCase()}'
            : 'Solde insuffisant (${_fmtPts(balance)} pts)',
        amountLabel: pointsLabel,
        sourcePrice: target.sourcePrice,
        amountFcfa: target.amountFcfa,
        payWithPoints: true,
        enabled: enabled,
        pointsRequired: pointsRequired,
        pointsBalance: balance,
      ),
    ];
  }

  static String _fmtPts(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  State<PaymentBillingPickerSheet> createState() =>
      _PaymentBillingPickerSheetState();
}

class _PaymentBillingPickerSheetState extends State<PaymentBillingPickerSheet> {
  late String _selectedKey;

  @override
  void initState() {
    super.initState();
    final firstEnabled = widget.choices.firstWhere(
      (c) => c.enabled,
      orElse: () => widget.choices.first,
    );
    _selectedKey = _keyOf(firstEnabled);
  }

  String _keyOf(PaymentBillingChoice c) =>
      '${c.payWithPoints ? 'points' : 'cash'}:${c.billingType}';

  PaymentBillingChoice get _selected => widget.choices.firstWhere(
    (c) => _keyOf(c) == _selectedKey && c.enabled,
    orElse: () => widget.choices.firstWhere(
      (c) => c.enabled,
      orElse: () => widget.choices.first,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.enabled;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151518),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.offerTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choisissez la période de paiement',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 16),
            for (final choice in widget.choices) ...[
              _BillingTile(
                choice: choice,
                selected: _keyOf(choice) == _selectedKey,
                onTap: choice.enabled
                    ? () => setState(() => _selectedKey = _keyOf(choice))
                    : null,
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: FilledButton(
                onPressed: canContinue
                    ? () => Navigator.of(context).pop(_selected)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.or,
                  disabledBackgroundColor: const Color(0xFF3A3A40),
                  foregroundColor: AppColors.or_fonce,
                  disabledForegroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  _selected.payWithPoints
                      ? 'Payer avec mes points'
                      : 'Continuer',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingTile extends StatelessWidget {
  const _BillingTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final PaymentBillingChoice choice;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = choice.enabled;
    final titleColor = enabled ? Colors.white : Colors.white38;
    final subColor = enabled
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.28);
    final amountColor = enabled ? Colors.white : Colors.white38;
    final borderColor = !enabled
        ? const Color(0xFF2A2A2E)
        : selected
        ? AppColors.or
        : const Color(0xFF3A3A40);

    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: Material(
        color: enabled ? const Color(0xFF1C1C20) : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: selected && enabled ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            choice.title,
                            style: TextStyle(
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          if (choice.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: enabled
                                    ? AppColors.or
                                    : const Color(0xFF3A3A40),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'Conseillé',
                                style: TextStyle(
                                  color: enabled
                                      ? AppColors.or_fonce
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          if (choice.payWithPoints) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.stars_rounded,
                              size: 18,
                              color: enabled ? AppColors.or : Colors.white38,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        choice.subtitle,
                        style: TextStyle(color: subColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  choice.amountLabel,
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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
