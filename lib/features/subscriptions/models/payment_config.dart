class PaymentConfig {
  const PaymentConfig({required this.paymentsEnabled});

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    return PaymentConfig(
      paymentsEnabled: json['paymentsEnabled'] as bool? ?? false,
    );
  }

  final bool paymentsEnabled;
}

class CheckoutSession {
  const CheckoutSession({
    required this.checkoutUrl,
    required this.sessionId,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      checkoutUrl: json['checkoutUrl'] as String,
      sessionId: json['sessionId'] as String,
    );
  }

  final String checkoutUrl;
  final String sessionId;
}
