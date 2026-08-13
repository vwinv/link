class PaymentConfig {
  const PaymentConfig({
    required this.paymentsEnabled,
    this.provider = 'none',
  });

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    return PaymentConfig(
      paymentsEnabled: json['paymentsEnabled'] as bool? ?? false,
      provider: json['provider'] as String? ?? 'none',
    );
  }

  final bool paymentsEnabled;
  final String provider;
}

class CheckoutSession {
  const CheckoutSession({
    required this.checkoutUrl,
    required this.invoiceToken,
    this.sessionId,
    this.amountFcfa,
    this.description,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    final token = (json['invoiceToken'] as String?) ??
        (json['sessionId'] as String?) ??
        '';
    return CheckoutSession(
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
      invoiceToken: token,
      sessionId: json['sessionId'] as String? ?? token,
      amountFcfa: (json['amountFcfa'] as num?)?.toInt(),
      description: json['description'] as String?,
    );
  }

  final String checkoutUrl;
  final String invoiceToken;
  final String? sessionId;
  final int? amountFcfa;
  final String? description;
}

class SoftPayResult {
  const SoftPayResult({
    required this.message,
    this.url,
    this.omUrl,
    this.maxitUrl,
    this.returnUrl,
    this.fees,
    this.currency,
  });

  factory SoftPayResult.fromJson(Map<String, dynamic> json) {
    final sp = json['softPay'];
    final map = sp is Map ? Map<String, dynamic>.from(sp) : json;
    String? om;
    String? mx;
    final ou = map['other_url'];
    if (ou is Map) {
      om = ou['om_url']?.toString();
      mx = ou['maxit_url']?.toString();
    }
    return SoftPayResult(
      message: map['message']?.toString() ??
          'Suivez les instructions pour finaliser le paiement.',
      url: map['url']?.toString(),
      omUrl: om,
      maxitUrl: mx,
      returnUrl: map['return_url']?.toString(),
      fees: map['fees'] is num ? map['fees'] as num : null,
      currency: map['currency']?.toString(),
    );
  }

  final String message;
  final String? url;
  final String? omUrl;
  final String? maxitUrl;
  final String? returnUrl;
  final num? fees;
  final String? currency;

  bool get hasLaunchableUrl =>
      (url?.trim().isNotEmpty ?? false) ||
      (omUrl?.trim().isNotEmpty ?? false) ||
      (maxitUrl?.trim().isNotEmpty ?? false);
}
