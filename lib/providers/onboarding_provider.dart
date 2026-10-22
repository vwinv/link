import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingProvider extends ChangeNotifier {
  static const _completedKey = 'onboarding_completed';

  bool _hasCompleted = false;
  bool _isLoaded = false;

  bool get hasCompletedOnboarding => _hasCompleted;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompleted = prefs.getBool(_completedKey) ?? false;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    _hasCompleted = true;
    notifyListeners();
  }
}
