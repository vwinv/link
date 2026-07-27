import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/wallet/models/wallet_add_result.dart';
import 'package:linkflutter/features/wallet/models/wallet_platform_type.dart';

class WalletApiService {
  WalletApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<WalletAddResult> addCardToWallet({
    required String cardId,
    required WalletPlatformType platform,
  }) async {
    final response = await _apiClient.post(
      '/wallet/cards/$cardId/add',
      body: {
        'walletType': platform.apiValue,
      },
      authenticated: true,
    );

    return WalletAddResult.fromJson(response);
  }
}
