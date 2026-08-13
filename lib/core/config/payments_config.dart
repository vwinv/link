/// Configuration des paiements côté application (PayDunya SoftPay).
abstract final class PaymentsConfig {
  /// Force l'activation instantanée sans SoftPay (tests locaux).
  /// `flutter run --dart-define=FORCE_INSTANT_SUBSCRIBE=true`
  static const forceInstantSubscribe = bool.fromEnvironment(
    'FORCE_INSTANT_SUBSCRIBE',
    defaultValue: false,
  );

  /// Résout si le flux PayDunya SoftPay doit être utilisé.
  static bool usePaydunyaSoftPay(bool apiPaymentsEnabled) {
    if (forceInstantSubscribe) return false;
    return apiPaymentsEnabled;
  }

  @Deprecated('Utiliser usePaydunyaSoftPay')
  static bool useStripeCheckout(bool apiPaymentsEnabled) =>
      usePaydunyaSoftPay(apiPaymentsEnabled);
}
