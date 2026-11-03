import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_config.dart';

/// Signal global : la dernière requête n’a pas pu joindre Internet.
class NetworkStatus extends ChangeNotifier {
  static const offlineMessage =
      'Problème de connexion. Vérifiez votre accès à Internet, puis réessayez.';

  var _offline = false;
  var _checking = false;

  bool get isOffline => _offline;
  bool get isChecking => _checking;

  void reportOffline() {
    if (_offline) return;
    _offline = true;
    notifyListeners();
  }

  void reportOnline() {
    if (!_offline && !_checking) return;
    _offline = false;
    _checking = false;
    notifyListeners();
  }

  /// Confirme que l’API répond avant de retirer le message.
  Future<void> recheck() async {
    if (_checking) return;
    _checking = true;
    notifyListeners();

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 4);
    try {
      final request = await client.getUrl(Uri.parse(ApiConfig.baseUrl));
      final response = await request.close().timeout(
        const Duration(seconds: 4),
      );
      await response.drain<void>();
      _offline = false;
    } catch (_) {
      _offline = true;
    } finally {
      client.close(force: true);
      _checking = false;
      notifyListeners();
    }
  }
}

/// Une image ou une requête annulée ne doit pas masquer toute la page.
bool isFatalPageLoadError({bool? isForMainFrame, int? errorCode}) {
  if (isForMainFrame == false) return false;
  // Annulé (iOS -999, Android ERR_ABORTED -3) : souvent un changement de page.
  if (errorCode == -999 || errorCode == -3) return false;
  return true;
}

bool looksLikeOfflineWebError({
  int? errorCode,
  String? description,
  String? errorTypeName,
}) {
  const types = {'connect', 'hostLookup', 'timeout', 'failedSslHandshake'};
  if (errorTypeName != null && types.contains(errorTypeName)) return true;

  const offlineCodes = {-1009, -1004, -1003, -1001, -2};
  if (errorCode != null && offlineCodes.contains(errorCode)) return true;

  final text = (description ?? '').toLowerCase();
  return text.contains('internet') ||
      text.contains('offline') ||
      text.contains('network') ||
      text.contains('timed out') ||
      text.contains('connexion');
}
