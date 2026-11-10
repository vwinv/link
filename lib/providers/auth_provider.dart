import 'dart:convert';

import 'package:linkflutter/core/bootstrap/workspace_local_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/features/auth/models/user.dart';
import 'package:linkflutter/features/auth/services/auth_api_service.dart';
import 'package:linkflutter/features/auth/services/social_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthApiService authApi,
    required ApiClient apiClient,
    required SocialAuthService socialAuth,
  })  : _authApi = authApi,
        _apiClient = apiClient,
        _socialAuth = socialAuth {
    _apiClient.onUnauthorized = _handleUnauthorized;
  }

  static const _tokenKey = 'access_token';
  static const _userKey = 'user_json';

  final AuthApiService _authApi;
  final ApiClient _apiClient;
  final SocialAuthService _socialAuth;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;
  User? _user;
  var _pendingReferralPrompt = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  /// Compte OAuth créé sans code : proposer la saisie à la création.
  bool get pendingReferralPrompt => _pendingReferralPrompt;

  bool consumeReferralPrompt() {
    if (!_pendingReferralPrompt) return false;
    _pendingReferralPrompt = false;
    return true;
  }

  /// Restaure la session locale puis la valide auprès du serveur.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token == null || userJson == null) {
      await _clearStoredSession(prefs);
      _clearSession();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _apiClient.setAccessToken(token);

    try {
      final user = await _authApi.getCurrentUser();
      await _persistSession(token, user);
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _clearStoredSession(prefs);
        _clearSession();
      } else {
        // Serveur injoignable : on conserve la session locale.
        _restoreLocalSession(token, userJson);
      }
    } catch (_) {
      _restoreLocalSession(token, userJson);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _authenticate(() => _authApi.login(email: email, password: password));
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? referralCode,
  }) async {
    return _authenticate(
      () => _authApi.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        referralCode: referralCode,
      ),
    );
  }

  Future<bool> signInWithGoogle({String? referralCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final idToken = await _socialAuth.signInWithGoogle();
      final result = await _authApi.loginWithGoogle(
        idToken: idToken,
        referralCode: referralCode,
      );
      await _persistSession(
        result.accessToken,
        result.user,
        pendingReferralPrompt: result.needsReferralPrompt,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on SocialAuthCancelled {
      _isLoading = false;
      notifyListeners();
      return false;
    } on SocialAuthMisconfigured catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = 'Connexion Google impossible: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple({String? referralCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _socialAuth.signInWithApple();
      final result = await _authApi.loginWithApple(
        idToken: credential.idToken,
        firstName: credential.firstName,
        lastName: credential.lastName,
        referralCode: referralCode,
      );
      await _persistSession(
        result.accessToken,
        result.user,
        pendingReferralPrompt: result.needsReferralPrompt,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on SocialAuthCancelled {
      _isLoading = false;
      notifyListeners();
      return false;
    } on SocialAuthMisconfigured catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Connexion Apple impossible';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _authenticate(
    Future<({String accessToken, User user, bool needsReferralPrompt})>
            Function()
        request,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await request();
      await _persistSession(result.accessToken, result.user);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible de contacter le serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistSession(
    String token,
    User user, {
    bool pendingReferralPrompt = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    _apiClient.setAccessToken(token);
    _user = user;
    _isAuthenticated = true;
    _pendingReferralPrompt = pendingReferralPrompt;
  }

  void _restoreLocalSession(String token, String userJson) {
    _apiClient.setAccessToken(token);
    _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    _isAuthenticated = true;
  }

  Future<bool> requestPasswordReset({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authApi.requestPasswordReset(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Impossible d’envoyer l’e-mail de réinitialisation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // On nettoie quand même la session locale.
    }
    final userId = _user?.id;
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await WorkspaceLocalCache.clearForUser(userId);
    }
    await _clearStoredSession(prefs);
    _clearSession();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authApi.deleteAccount();

    final userId = _user?.id;
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await WorkspaceLocalCache.clearForUser(userId);
    }
    await _clearStoredSession(prefs);
    _clearSession();
    notifyListeners();
  }

  Future<void> updateLocalProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  }) async {
    final current = _user;
    if (current == null) return;

    final updated = User(
      id: current.id,
      email: email?.trim().isNotEmpty == true ? email!.trim() : current.email,
      firstName: firstName,
      lastName: lastName,
      phone: phone?.trim().isNotEmpty == true ? phone!.trim() : null,
      avatarUrl: current.avatarUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      await _persistSession(token, updated);
    } else {
      _user = updated;
      notifyListeners();
    }
  }

  void _handleUnauthorized() {
    if (!_isAuthenticated) return;
    logout();
  }

  Future<void> _clearStoredSession(SharedPreferences prefs) async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('user_subscription_cache');
  }

  void _clearSession() {
    _apiClient.setAccessToken(null);
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
  }
}
