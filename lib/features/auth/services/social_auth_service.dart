import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkflutter/core/config/oauth_config.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthCancelled implements Exception {
  @override
  String toString() => 'Connexion annulée';
}

class SocialAuthMisconfigured implements Exception {
  SocialAuthMisconfigured(this.message);

  final String message;

  @override
  String toString() => message;
}

class SocialAuthService {
  bool _googleInitialized = false;

  Future<String> signInWithGoogle() async {
    if (!OAuthConfig.isGoogleConfigured) {
      throw SocialAuthMisconfigured(
        'Google Sign-In n’est pas configuré (GOOGLE_WEB_CLIENT_ID)',
      );
    }

    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: OAuthConfig.googleIosClientId.isEmpty
            ? null
            : OAuthConfig.googleIosClientId,
        serverClientId: OAuthConfig.googleWebClientId,
      );
      _googleInitialized = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw SocialAuthMisconfigured('Token Google indisponible');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw SocialAuthCancelled();
      }
      throw SocialAuthMisconfigured(
        'Connexion Google impossible (${error.code.name})',
      );
    }
  }

  Future<({String idToken, String? firstName, String? lastName})>
      signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw SocialAuthMisconfigured('Token Apple indisponible');
      }

      return (
        idToken: idToken,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw SocialAuthCancelled();
      }
      throw SocialAuthMisconfigured(
        'Connexion Apple impossible (${error.code.name})',
      );
    } on SignInWithAppleNotSupportedException {
      throw SocialAuthMisconfigured(
        'Sign in with Apple n’est pas disponible sur cet appareil',
      );
    }
  }
}
