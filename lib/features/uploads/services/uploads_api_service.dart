import 'package:linkflutter/core/api/api_client.dart';

class UploadsApiService {
  UploadsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<String> uploadImage(String filePath) async {
    final response = await _apiClient.uploadMultipart(
      '/uploads/image',
      fieldName: 'file',
      filePath: filePath,
      authenticated: true,
    );
    final url = response['url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('URL d’image invalide');
    }
    return url;
  }
}
