class PremiumOfferPrice {
  const PremiumOfferPrice({
    required this.id,
    required this.billingType,
    this.priceLabel,
    required this.priceAmount,
    this.pricePerSeat,
    required this.currency,
    this.discountPercent,
    this.badgeLabel,
    required this.isPopular,
    required this.sortOrder,
    this.appleProductId,
  });

  factory PremiumOfferPrice.fromJson(Map<String, dynamic> json) {
    return PremiumOfferPrice(
      id: json['id'] as String,
      billingType: json['billingType'] as String,
      priceLabel: json['priceLabel'] as String?,
      priceAmount: (json['priceAmount'] as num).toDouble(),
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'FCFA',
      discountPercent: json['discountPercent'] as int?,
      badgeLabel: json['badgeLabel'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      appleProductId: json['appleProductId'] as String?,
    );
  }

  final String id;
  final String billingType;
  final String? priceLabel;
  final double priceAmount;
  final double? pricePerSeat;
  final String currency;
  final int? discountPercent;
  final String? badgeLabel;
  final bool isPopular;
  final int sortOrder;
  final String? appleProductId;

  bool get isPerSeat => pricePerSeat != null && pricePerSeat! > 0;

  double get unitPrice => isPerSeat ? pricePerSeat! : priceAmount;

  /// Total = prix de base + (sièges au-delà du minimum × prix/utilisateur supplémentaire).
  double totalForSeats(int seats, {int includedSeats = 1}) {
    if (!isPerSeat) return priceAmount;
    final base = includedSeats < 1 ? 1 : includedSeats;
    final extra = seats > base ? seats - base : 0;
    return priceAmount + unitPrice * extra;
  }

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
    if (isPerSeat) {
      return '${_formatAmount(priceAmount)} $currency'
          ' + ${_formatAmount(unitPrice)} $currency / utilisateur supplémentaire';
    }
    return '${_formatAmount(priceAmount)} $currency';
  }

  String displayTotal(int seats, {int includedSeats = 1}) {
    return '${_formatAmount(totalForSeats(seats, includedSeats: includedSeats))} $currency';
  }

  String extraSeatLabel() {
    return '${_formatAmount(unitPrice)} $currency / utilisateur supplémentaire';
  }

  static String formatAmount(double amount) => _formatAmount(amount);

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
