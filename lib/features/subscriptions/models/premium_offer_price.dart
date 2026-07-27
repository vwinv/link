class PremiumOfferPrice {
  const PremiumOfferPrice({
    required this.id,
    required this.billingType,
    this.priceLabel,
    required this.priceAmount,
    required this.currency,
    this.discountPercent,
    this.badgeLabel,
    required this.isPopular,
    required this.sortOrder,
  });

  factory PremiumOfferPrice.fromJson(Map<String, dynamic> json) {
    return PremiumOfferPrice(
      id: json['id'] as String,
      billingType: json['billingType'] as String,
      priceLabel: json['priceLabel'] as String?,
      priceAmount: (json['priceAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'FCFA',
      discountPercent: json['discountPercent'] as int?,
      badgeLabel: json['badgeLabel'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  final String id;
  final String billingType;
  final String? priceLabel;
  final double priceAmount;
  final String currency;
  final int? discountPercent;
  final String? badgeLabel;
  final bool isPopular;
  final int sortOrder;

  String get title {
    switch (billingType.toUpperCase()) {
      case 'YEARLY':
        return 'Annuel';
      case 'LIFETIME':
        return 'À vie';
      case 'MONTHLY':
      default:
        return 'Mensuel';
    }
  }

  String? get subtitle {
    switch (billingType.toUpperCase()) {
      case 'YEARLY':
        return 'par an';
      case 'LIFETIME':
        return 'paiement unique';
      case 'MONTHLY':
        return 'par mois';
      default:
        return null;
    }
  }

  String get displayPrice {
    if (priceLabel != null && priceLabel!.isNotEmpty) {
      return priceLabel!;
    }
    return '${_formatAmount(priceAmount)} $currency';
  }

  static String _formatAmount(double amount) {
    final value = amount.round();
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    if (value < 0) buffer.write('-');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
