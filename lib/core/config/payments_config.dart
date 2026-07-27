/// Configuration des paiements Stripe côté application.
abstract final class PaymentsConfig {
  /// Force l'activation instantanée sans Stripe (tests locaux).
  /// `flutter run --dart-define=FORCE_INSTANT_SUBSCRIBE=true`
  static const forceInstantSubscribe = bool.fromEnvironment(
    'FORCE_INSTANT_SUBSCRIBE',
    defaultValue: false,
  );

  /// Résout si le flux Stripe Checkout doit être utilisé.
  static bool useStripeCheckout(bool apiPaymentsEnabled) {
    if (forceInstantSubscribe) return false;
    return apiPaymentsEnabled;
  }
}
