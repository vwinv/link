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
    int? seats,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/subscribe',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
        if (seats != null) 'seats': seats,
      },
    );
    return UserSubscription.fromJson(response);
  }

  Future<({String firstName, String offerTitle})> createSignupRequest({
    required String offerSlug,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/signup-request',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
        if (seats != null) 'seats': seats,
      },
    );
    return (
      firstName: response['firstName'] as String? ?? '',
      offerTitle: response['offerTitle'] as String? ?? '',
    );
  }

  Future<CheckoutSession> createCheckoutSession({
    required String offerSlug,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/checkout',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
        if (seats != null) 'seats': seats,
      },
    );
    return CheckoutSession.fromJson(response);
  }

  Future<SoftPayResult> softPay({
    required String offerSlug,
    required String billingType,
    required String invoiceToken,
    required String method,
    required String prenom,
    required String nom,
    required String telephone,
    String? email,
    String? teamId,
    int? seats,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/softpay',
      authenticated: true,
      body: {
        'offerSlug': offerSlug,
        'billingType': billingType,
        'invoiceToken': invoiceToken,
        'method': method,
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (teamId != null) 'teamId': teamId,
        if (seats != null) 'seats': seats,
      },
    );
    return SoftPayResult.fromJson(response);
  }

  Future<({bool paid, UserSubscription? subscription})> confirmPaydunya({
    required String invoiceToken,
  }) async {
    final encoded = Uri.encodeQueryComponent(invoiceToken);
    final response = await _apiClient.get(
      '/subscriptions/paydunya/confirm?invoiceToken=$encoded',
      authenticated: true,
    );
    final paid = response['paid'] == true;
    UserSubscription? subscription;
    final raw = response['subscription'];
    if (raw is Map<String, dynamic>) {
      subscription = UserSubscription.fromJson(raw);
    } else if (raw is Map) {
      subscription = UserSubscription.fromJson(Map<String, dynamic>.from(raw));
    }
    return (paid: paid, subscription: subscription);
  }
}
