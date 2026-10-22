import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer_price.dart';

/// Choix de facturation avant paiement : annuel proposé en premier (mensuel × 12).
class PaymentBillingChoice {
  const PaymentBillingChoice({
    required this.billingType,
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.sourcePrice,
    this.isRecommended = false,
  });

  final String billingType;
  final String title;
  final String subtitle;
  final String amountLabel;
  final PremiumOfferPrice sourcePrice;
  final bool isRecommended;

  static List<PaymentBillingChoice> forOffer({
    required PremiumOffer offer,
    required PremiumOfferPrice selectedPrice,
    required int seats,
  }) {
    final monthly = offer.monthlyPrice ??
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
        ),
      );
    }

    final selectedType = selectedPrice.billingType.toUpperCase();
    if (selectedType != 'MONTHLY' &&
        selectedType != 'YEARLY' &&
        choices.every((c) => c.sourcePrice.id != selectedPrice.id)) {
      choices.add(
        PaymentBillingChoice(
          billingType: selectedPrice.billingType,
          title: selectedPrice.title,
          subtitle: selectedPrice.subtitle ?? '',
          amountLabel: _amountLabel(selectedPrice, seats, included),
          sourcePrice: selectedPrice,
        ),
      );
    }

    if (choices.isEmpty) {
      choices.add(
        PaymentBillingChoice(
          billingType: selectedPrice.billingType,
          title: selectedPrice.title,
          subtitle: selectedPrice.subtitle ?? '',
          amountLabel: _amountLabel(selectedPrice, seats, included),
          sourcePrice: selectedPrice,
          isRecommended: true,
        ),
      );
    }

    return choices;
  }

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
  }) {
    if (choices.isEmpty) return Future.value(null);
    if (choices.length == 1) return Future.value(choices.first);

    return showModalBottomSheet<PaymentBillingChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentBillingPickerSheet(
        offerTitle: offerTitle,
        choices: choices,
      ),
    );
  }

  @override
  State<PaymentBillingPickerSheet> createState() =>
      _PaymentBillingPickerSheetState();
}

class _PaymentBillingPickerSheetState extends State<PaymentBillingPickerSheet> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.choices.first.billingType;
  }

  PaymentBillingChoice get _selected => widget.choices.firstWhere(
        (c) => c.billingType == _selectedType,
        orElse: () => widget.choices.first,
      );

  @override
  Widget build(BuildContext context) {
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
                selected: choice.billingType == _selectedType,
                onTap: () => setState(() => _selectedType = choice.billingType),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: AppSizes.buttonHeight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_selected),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.or,
                  foregroundColor: AppColors.or_fonce,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1C1C20),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.or : const Color(0xFF3A3A40),
              width: selected ? 1.5 : 1,
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
                          style: const TextStyle(
                            color: Colors.white,
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
                              color: AppColors.or,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'Conseillé',
                              style: TextStyle(
                                color: AppColors.or_fonce,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      choice.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                choice.amountLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
