import 'package:linkflutter/core/api/api_client.dart';

class SharingApiService {
  SharingApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> recordShare({
    required String cardId,
    required String method,
  }) async {
    try {
      await _apiClient.post(
        '/sharing/cards/$cardId/share',
        body: {'method': method},
        authenticated: true,
      );
    } catch (_) {
      // Le partage natif reste utilisable même si l’analytics échoue.
    }
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
      // Stat analytics — ne bloque pas l’enregistrement contact.
    }
  }
}
