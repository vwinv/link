/// Configuration des paiements côté application (PayDunya SoftPay).
abstract final class PaymentsConfig {
  /// Force l'activation instantanée sans SoftPay (tests locaux).
  /// `flutter run --dart-define=FORCE_INSTANT_SUBSCRIBE=true`
  static const forceInstantSubscribe = bool.fromEnvironment(
    'FORCE_INSTANT_SUBSCRIBE',
    defaultValue: false,
  );

  /// Résout si le flux PayDunya SoftPay doit être utilisé.
  /// L’IAP Apple (iOS + HIDE_IN_APP_PAYMENTS) est un chemin UI distinct.
  static bool usePaydunyaSoftPay({
    required bool apiPaymentsEnabled,
  }) {
    if (forceInstantSubscribe) return false;
    return apiPaymentsEnabled;
  }

  @Deprecated('Utiliser usePaydunyaSoftPay')
  static bool useStripeCheckout(bool apiPaymentsEnabled) =>
      usePaydunyaSoftPay(apiPaymentsEnabled: apiPaymentsEnabled);
}
