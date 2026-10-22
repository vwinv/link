import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/notifications/models/app_notification.dart';

class NotificationsApiService {
  NotificationsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<NotificationsPage> fetchMine({int page = 1, int limit = 30}) async {
    final response = await _apiClient.get(
      '/notifications?page=$page&limit=$limit',
      authenticated: true,
    );
    return NotificationsPage.fromJson(response);
  }

  Future<int> fetchUnreadCount() async {
    final response = await _apiClient.get(
      '/notifications/unread-count',
      authenticated: true,
    );
    return response['count'] as int? ?? 0;
  }

  Future<AppNotification> markRead(String id) async {
    final response = await _apiClient.patch(
      '/notifications/$id/read',
      authenticated: true,
    );
    return AppNotification.fromJson(response);
  }

  Future<void> markAllRead() async {
    await _apiClient.post(
      '/notifications/read-all',
      authenticated: true,
    );
  }

  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    await _apiClient.put(
      '/devices/push-token',
      authenticated: true,
      body: {
        'token': token,
        'platform': platform,
      },
    );
  }

  Future<void> unregisterPushToken(String token) async {
    await _apiClient.deleteWithBody(
      '/devices/push-token',
      authenticated: true,
      body: {'token': token},
    );
  }
}
