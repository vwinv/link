import 'package:flutter/foundation.dart';

/// Signale à l’accueil qu’il faut relire les analytics (vues, partages, enregistrées).
class CardAnalyticsRefreshNotifier extends ChangeNotifier {
  int _sharesDelta = 0;

  int consumeSharesDelta() {
    final delta = _sharesDelta;
    _sharesDelta = 0;
    return delta;
  }

  void requestRefresh({int sharesDelta = 0}) {
    if (sharesDelta > 0) {
      _sharesDelta += sharesDelta;
    }
    notifyListeners();
  }
}
