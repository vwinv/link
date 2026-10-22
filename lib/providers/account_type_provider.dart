import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/auth/models/account_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountTypeProvider extends ChangeNotifier {
  static const _completedKey = 'account_type_completed';
  static const _intentKey = 'auth_flow_intent';

  AccountType? _selectedType;
  bool _hasCompleted = false;
  bool _isLoaded = false;

  AccountType? get selectedType => _selectedType;
  bool get hasCompletedAccountType => _hasCompleted;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompleted = prefs.getBool(_completedKey) ?? false;
    _selectedType = _parseType(prefs.getString(_intentKey));
    _isLoaded = true;
    notifyListeners();
  }

  void select(AccountType type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<void> setAuthFlowIntent(AccountType type) async {
    _selectedType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_intentKey, type.name);
    notifyListeners();
  }

  /// Lit et efface l'intention (perso / équipe) du parcours d'inscription en cours.
  Future<AccountType?> consumeAuthFlowIntent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_intentKey);
    await prefs.remove(_intentKey);

    final consumed = _parseType(raw) ?? _selectedType;
    if (raw != null) {
      _selectedType = consumed;
      notifyListeners();
    }
    return consumed;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    _hasCompleted = true;
    notifyListeners();
  }

  void clear() {
    _selectedType = null;
    notifyListeners();
  }

  AccountType? _parseType(String? raw) {
    if (raw == AccountType.team.name) return AccountType.team;
    if (raw == AccountType.personal.name) return AccountType.personal;
    return null;
  }
}
