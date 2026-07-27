import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/scan/models/ai_scan_quota.dart';

class ScansApiService {
  ScansApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AiScanQuota> fetchQuota() async {
    final response = await _apiClient.get(
      '/scans/quota',
      authenticated: true,
    );
    return AiScanQuota.fromJson(Map<String, dynamic>.from(response));
  }

  Future<AiScanQuota> recordScan({Map<String, dynamic>? contact}) async {
    final response = await _apiClient.post(
      '/scans',
      body: contact ?? const {},
      authenticated: true,
    );
    final quota = response['quota'];
    if (quota is Map) {
      return AiScanQuota.fromJson(Map<String, dynamic>.from(quota));
    }
    return fetchQuota();
  }
}
