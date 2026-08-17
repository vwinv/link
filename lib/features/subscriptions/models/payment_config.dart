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
    this.qrImageBase64,
    this.returnUrl,
    this.fees,
    this.currency,
  });

  factory SoftPayResult.fromJson(Map<String, dynamic> json) {
    final sp = json['softPay'];
    final map = sp is Map ? Map<String, dynamic>.from(sp) : json;
    String? om = map['om_url']?.toString();
    String? mx = map['maxit_url']?.toString();
    final ou = map['other_url'] ?? map['otherUrl'];
    if (ou is Map) {
      om ??= ou['om_url']?.toString() ?? ou['omUrl']?.toString();
      mx ??= ou['maxit_url']?.toString() ?? ou['maxitUrl']?.toString();
    }
    return SoftPayResult(
      message: map['message']?.toString() ??
          'Suivez les instructions pour finaliser le paiement.',
      url: map['url']?.toString(),
      omUrl: om,
      maxitUrl: mx,
      qrImageBase64: map['qr_image_base64']?.toString() ??
          map['qrImageBase64']?.toString(),
      returnUrl: map['return_url']?.toString() ?? map['returnUrl']?.toString(),
      fees: map['fees'] is num ? map['fees'] as num : null,
      currency: map['currency']?.toString(),
    );
  }

  final String message;
  final String? url;
  final String? omUrl;
  final String? maxitUrl;
  /// PNG Orange Money (base64) fourni par PayDunya dans `data[qrcode]`.
  final String? qrImageBase64;
  final String? returnUrl;
  final num? fees;
  final String? currency;

  bool get hasLaunchableUrl =>
      (omUrl?.trim().isNotEmpty ?? false) ||
      (maxitUrl?.trim().isNotEmpty ?? false) ||
      (url?.trim().isNotEmpty ?? false);
}
