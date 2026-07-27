import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/subscriptions/models/payment_config.dart';
import 'package:linkflutter/features/subscriptions/models/premium_offer.dart';
import 'package:linkflutter/features/subscriptions/models/user_subscription.dart';

class SubscriptionsApiService {
  SubscriptionsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<PaymentConfig> fetchPaymentConfig() async {
    final response = await _apiClient.get('/subscriptions/config');
    return PaymentConfig.fromJson(response);
  }

  Future<List<PremiumOffer>> fetchOffers() async {
    final response = await _apiClient.getList('/subscriptions/offers');
    return response
        .map((item) => PremiumOffer.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserSubscription?> fetchMySubscription() async {
    try {
      final response = await _apiClient.get(
        '/subscriptions/me',
        authenticated: true,
      );
      return UserSubscription.fromJson(response);
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<UserSubscription> subscribe({
    required String offerSlug,
    required String billingType,
    String? teamId,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/subscribe',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
      },
    );
    return UserSubscription.fromJson(response);
  }

  Future<CheckoutSession> createCheckoutSession({
    required String offerSlug,
    required String billingType,
    String? teamId,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/checkout',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
      },
    );
    return CheckoutSession.fromJson(response);
  }
}
