import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  fr,
  en;

  Locale get locale => Locale(name);

  static AppLanguage fromCode(String? code) {
    return code == 'en' ? AppLanguage.en : AppLanguage.fr;
  }

  /// Français ou anglais selon la langue système ; anglais pour tout le reste.
  static AppLanguage fromSystemLocale([Locale? locale]) {
    switch ((locale ?? ui.PlatformDispatcher.instance.locale).languageCode) {
      case 'fr':
        return AppLanguage.fr;
      case 'en':
        return AppLanguage.en;
      default:
        return AppLanguage.en;
    }
  }
}

class LocaleProvider extends ChangeNotifier {
  static const _languageKey = 'app_language';

  Locale _locale = AppLanguage.fromSystemLocale().locale;
  var _hasLoaded = false;

  Locale get locale => _locale;
  bool get hasLoaded => _hasLoaded;
  AppLanguage get language => AppLanguage.fromCode(_locale.languageCode);

  LocaleProvider() {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    _locale = saved != null
        ? Locale(saved)
        : AppLanguage.fromSystemLocale().locale;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_locale.languageCode == language.name) return;

    _locale = language.locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);
  }
}
