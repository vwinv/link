import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

abstract final class ApiConfig {
  static const _port = 3000;
  static const _apiPrefix = '/api/v1';

  /// URL publique des cartes partagées (QR, WhatsApp, Universal Links).
  /// Local API : `--dart-define=API_HOST=192.168.x.x` ou `API_BASE_URL=...`
  //static const defaultPublicBaseUrl = 'https://api.dropone.pro';
  static String get defaultPublicBaseUrl {
    if (kIsWeb) return 'http://localhost:$_port';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_port';
    // iOS simulator : 10.0.2.2 n’existe pas, et `localhost` peut résoudre en IPv6.
    return 'http://0.0.0.0:$_port';
  }

  /// Backend local uniquement si tu passes :
  /// `flutter run --dart-define=API_HOST=192.168.1.42`
  static String get _localHost {
    const override = String.fromEnvironment('API_HOST');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static bool get _useLocalApi {
    const apiBase = String.fromEnvironment('API_BASE_URL');
    const hostOverride = String.fromEnvironment('API_HOST');
    return apiBase.isEmpty && hostOverride.isNotEmpty;
  }

  /// URL de base pour les liens partagés (QR, WhatsApp, copier le lien).
  static String get publicBaseUrl {
    const override = String.fromEnvironment('APP_PUBLIC_URL');
    if (override.isNotEmpty) {
      return override.replaceAll(RegExp(r'/+$'), '');
    }
    return defaultPublicBaseUrl;
  }

  static String get _apiOrigin {
    const apiBase = String.fromEnvironment('API_BASE_URL');
    if (apiBase.isNotEmpty) {
      return apiBase.replaceAll(RegExp(r'/+$'), '');
    }

    if (_useLocalApi) {
      return 'http://$_localHost:$_port';
    }

    return publicBaseUrl;
  }

  static String get baseUrl => '$_apiOrigin$_apiPrefix';

  /// Résout une URL d’asset renvoyée par l’API (logos, images uploadées).
  static String? resolvePublicAssetUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) return trimmed;

      final apiOrigin = Uri.parse(_apiOrigin);
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return uri
            .replace(host: apiOrigin.host, port: apiOrigin.port)
            .toString();
      }
      return trimmed;
    }

    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$_apiOrigin$path';
  }

  /// Lien public partagé : `https://api.dropone.pro/cards/{slug}`
  /// Le host doit correspondre aux Associated Domains (iOS) et à l’intent-filter
  /// (Android), sinon le lien s’ouvre dans le navigateur au lieu de l’app.
  static String publicUrl(String slug) => '$publicBaseUrl/cards/$slug';

  /// App Store Drop One.
  /// Override : `--dart-define=APP_STORE_URL=https://apps.apple.com/...`
  static const appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: 'https://apps.apple.com/us/app/drop-one/id6807993018',
  );

  /// Play Store - à remplir après déploiement Android.
  /// Override : `--dart-define=PLAY_STORE_URL=https://play.google.com/store/apps/details?id=com.mega.dropone`
  static const playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.mega.dropone',
  );

  /// Page HTML chargée dans l’app (WebView), mode plein écran.
  static String publicPageLoadUrl(String slug) {
    final base = _useLocalApi ? '$_apiOrigin/cards/$slug' : publicUrl(slug);
    return '$base?embed=1';
  }

  /// Alias conservé pour compatibilité.
  static String publicPageUrl(String slug) => publicUrl(slug);
}
