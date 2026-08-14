/// Configuration OAuth 2.0 / OpenID Connect (Google + Apple).
///
/// Option 1 - fichier local (recommandé en dev) :
/// ```bash
/// cp oauth.env.json.example oauth.env.json
/// # puis remplir les IDs Google Cloud
/// flutter run --dart-define-from-file=oauth.env.json
/// ```
///
/// Option 2 - variables individuelles :
/// ```bash
/// flutter run \
///   --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com \
///   --dart-define=GOOGLE_IOS_CLIENT_ID=yyy.apps.googleusercontent.com
/// ```
abstract final class OAuthConfig {
  // Les client IDs OAuth Google ne sont pas des secrets : ils sont déjà
  // embarqués en clair dans l'app (Info.plist / OAuth.xcconfig). On les met
  // en valeur par défaut pour que la connexion fonctionne quel que soit le
  // mode de build (Xcode, TestFlight, `flutter run`). Surchargeable via
  // --dart-define / oauth.env.json.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '880526404169-0sopgh9eaqsn67i47bpbooo0a5la9s9i.apps.googleusercontent.com',
  );

  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '880526404169-oupm39ivodrfs20324kskvc84nffm7rj.apps.googleusercontent.com',
  );

  /// Bundle ID iOS - doit correspondre à `APPLE_CLIENT_ID` côté backend.
  static const appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: 'com.mega.dropone',
  );

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  /// Schéma URL iOS pour Google Sign-In (`com.googleusercontent.apps.…`).
  static String? get googleIosUrlScheme {
    final clientId = googleIosClientId;
    if (clientId.isEmpty) return null;

    final prefix = clientId.split('.').first;
    if (prefix.isEmpty) return null;
    return 'com.googleusercontent.apps.$prefix';
  }
}
