import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/sharing/models/share_quota.dart';

class SharingApiService {
  SharingApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<ShareQuota> fetchQuota() async {
    final response = await _apiClient.get(
      '/sharing/quota',
      authenticated: true,
    );
    return ShareQuota.fromJson(response);
  }

  /// Enregistre un partage et retourne le quota mis à jour.
  /// Lève [ApiException] si le quota est atteint.
  Future<ShareQuota?> recordShare({
    required String cardId,
    required String method,
  }) async {
    final response = await _apiClient.post(
      '/sharing/cards/$cardId/share',
      body: {'method': method},
      authenticated: true,
    );
    final quota = response['quota'];
    if (quota is Map) {
      return ShareQuota.fromJson(Map<String, dynamic>.from(quota));
    }
    return null;
  }

  Future<void> recordPublicCardView(String slug) async {
    try {
      // Sends Bearer when logged in so DropOne visitors are identified.
      await _apiClient.get(
        '/sharing/public/$slug?source=app',
        authenticated: true,
      );
    } catch (_) {
      // Analytics only.
    }
  }

  Future<void> recordPublicCardSave(String slug) async {
    try {
      await _apiClient.post(
        '/sharing/public/$slug/save',
        authenticated: true,
      );
    } catch (_) {
      // Stat analytics - ne bloque pas l’enregistrement contact.
    }
  }
}
