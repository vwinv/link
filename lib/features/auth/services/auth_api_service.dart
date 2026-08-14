import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/auth/models/user.dart';

class AuthApiService {
  AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<({String accessToken, User user})> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );

    return _parseAuthResponse(response);
  }

  Future<({String accessToken, User user})> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    return _parseAuthResponse(response);
  }

  Future<({String accessToken, User user})> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _apiClient.post(
      '/auth/oauth/google',
      body: {'idToken': idToken},
    );
    return _parseAuthResponse(response);
  }

  Future<({String accessToken, User user})> loginWithApple({
    required String idToken,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _apiClient.post(
      '/auth/oauth/apple',
      body: {
        'idToken': idToken,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
      },
    );
    return _parseAuthResponse(response);
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me', authenticated: true);
    return User.fromJson(response);
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete('/users/me', authenticated: true);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
      timeout: const Duration(seconds: 25),
    );
  }

  ({String accessToken, User user}) _parseAuthResponse(
    Map<String, dynamic> response,
  ) {
    return (
      accessToken: response['accessToken'] as String,
      user: User.fromJson(response['user'] as Map<String, dynamic>),
    );
  }
}
