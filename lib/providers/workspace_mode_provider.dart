import 'package:flutter/foundation.dart';
import 'package:linkflutter/features/auth/models/workspace_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkspaceModeProvider extends ChangeNotifier {
  static const _modeKey = 'workspace_mode';
  static const _memberLoginIntentKey = 'member_login_intent';

  WorkspaceMode _mode = WorkspaceMode.personal;
  bool _isLoaded = false;
  bool _memberLoginIntent = false;

  WorkspaceMode get mode => _mode;
  bool get isPersonal => _mode == WorkspaceMode.personal;
  bool get isMember => _mode == WorkspaceMode.member;
  bool get isLoaded => _isLoaded;
  bool get memberLoginIntent => _memberLoginIntent;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_modeKey);
    _mode = raw == WorkspaceMode.member.name
        ? WorkspaceMode.member
        : WorkspaceMode.personal;
    _memberLoginIntent = prefs.getBool(_memberLoginIntentKey) ?? false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setMode(WorkspaceMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
    notifyListeners();
  }

  Future<void> switchToPersonal() => setMode(WorkspaceMode.personal);

  Future<void> switchToMember() => setMode(WorkspaceMode.member);

  Future<void> setMemberLoginIntent(bool value) async {
    _memberLoginIntent = value;
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_memberLoginIntentKey, true);
    } else {
      await prefs.remove(_memberLoginIntentKey);
    }
    notifyListeners();
  }

  /// Lit et efface l’intention « se connecter en tant que membre ».
  Future<bool> consumeMemberLoginIntent() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_memberLoginIntentKey) ?? _memberLoginIntent;
    await prefs.remove(_memberLoginIntentKey);
    _memberLoginIntent = false;
    notifyListeners();
    return value;
  }

  void reset() {
    _mode = WorkspaceMode.personal;
    _memberLoginIntent = false;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_modeKey);
      prefs.remove(_memberLoginIntentKey);
    });
  }
}
