import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:linkflutter/core/deep_link/deep_link_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  static const _dismissedSlugKey = 'dismissed_public_card_slug';

  final AppLinks _appLinks;
  String? _pendingSlug;
  String? _dismissedSlug;
  StreamSubscription<Uri>? _subscription;
  var _initialized = false;
  var _nativeLinksAvailable = true;

  bool get isAvailable => _nativeLinksAvailable;

  bool isPublicCardDismissed(String slug) => _dismissedSlug == slug;

  String? consumePendingSlug() {
    final slug = _pendingSlug;
    _pendingSlug = null;
    return slug;
  }

  Future<void> dismissPublicCard(String slug) async {
    _dismissedSlug = slug;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedSlugKey, slug);
  }

  Future<void> _loadDismissedSlug() async {
    final prefs = await SharedPreferences.getInstance();
    _dismissedSlug = prefs.getString(_dismissedSlugKey);
  }

  Future<void> _clearDismissedSlug() async {
    _dismissedSlug = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedSlugKey);
  }

  Future<void>? _readyFuture;

  /// Attend que le lien initial ait été lu (évite les courses avec le splash).
  Future<void> ensureReady() => _readyFuture ?? Future.value();

  Future<void> initialize(void Function(String slug) onSlug) {
    if (_readyFuture != null) return _readyFuture!;
    _readyFuture = _initializeImpl(onSlug);
    return _readyFuture!;
  }

  Future<void> _initializeImpl(void Function(String slug) onSlug) async {
    if (_initialized) return;
    _initialized = true;

    await _loadDismissedSlug();

    try {
      final initialUri = await _appLinks.getInitialLink().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      final initialSlug = parseCardSlugFromUri(initialUri);
      if (initialSlug != null) {
        // Une ouverture via deep link doit toujours pouvoir réafficher la carte
        // (même si l’utilisateur l’avait fermée précédemment).
        await _clearDismissedSlug();
        _pendingSlug = initialSlug;
      }

      _subscription = _appLinks.uriLinkStream.listen(
        (uri) async {
          final slug = parseCardSlugFromUri(uri);
          if (slug == null) return;
          await _clearDismissedSlug();
          onSlug(slug);
        },
        onError: (_) {},
      );
    } on MissingPluginException {
      _nativeLinksAvailable = false;
      if (kDebugMode) {
        debugPrint(
          'Deep links indisponibles : relancez avec '
          '`flutter run` (pas hot reload) après ajout de app_links.',
        );
      }
    } on PlatformException {
      _nativeLinksAvailable = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }
}
