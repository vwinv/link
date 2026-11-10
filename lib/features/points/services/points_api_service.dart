import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/points/models/points_overview.dart';

class PointsApiService {
  PointsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<PointsOverview> fetchOverview() async {
    final response = await _apiClient.get(
      '/points/me',
      authenticated: true,
    );
    return PointsOverview.fromJson(response);
  }

  Future<void> applyReferralCode(String code) async {
    await _apiClient.post(
      '/points/referral-code',
      body: {'code': code.trim()},
      authenticated: true,
    );
  }

  Future<Map<String, dynamic>> redeemSubscription({
    required String offerSlug,
    required String billingType,
    String? teamId,
    int? seats,
  }) async {
    return _apiClient.post(
      '/points/redeem',
      body: {
        'productType': 'SUBSCRIPTION',
        'productRef': offerSlug,
        'billingType': billingType,
        if (teamId != null) 'teamId': teamId,
        if (seats != null) 'seats': seats,
      },
      authenticated: true,
    );
  }
}
