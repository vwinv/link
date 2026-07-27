import 'package:linkflutter/l10n/app_localizations.dart';

const accountDeletedErrorCode = 'ACCOUNT_DELETED';

extension AuthErrorL10n on AppLocalizations {
  String resolveAuthError(String message) {
    if (message == accountDeletedErrorCode) return authAccountDeleted;

    final normalized = message.toLowerCase();

    if (normalized.contains('google oauth non configuré') ||
        normalized.contains('google sign-in n’est pas configuré') ||
        normalized.contains('google_web_client_id')) {
      return authGoogleNotConfigured;
    }

    if (normalized.contains('apple oauth non configuré') ||
        normalized.contains('apple sign-in n’est pas configuré')) {
      return authAppleNotConfigured;
    }

    if (normalized.contains('connexion annulée') ||
        normalized.contains('sign-in cancelled')) {
      return authOAuthCancelled;
    }

    if (normalized.contains('un compte existe déjà avec cet email')) {
      return message;
    }

    return message;
  }
}
