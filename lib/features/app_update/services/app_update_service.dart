import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/features/app_update/models/app_version_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService extends ChangeNotifier {
  AppUpdateService(this._api);

  static const _dismissedVersionKey = 'app_update_dismissed_version';

  final ApiClient _api;
  AppUpdateRequirement? _pending;
  var _checking = false;

  AppUpdateRequirement? get pending => _pending;
  bool get hasPending => _pending != null;

  /// Contrôle silencieux ; l’UI (bottom sheet) s’affiche via [pending].
  Future<void> check() async {
    if (kIsWeb || _checking || _pending != null) return;
    _checking = true;

    try {
      final remote = await _fetchRemote();
      final package = await PackageInfo.fromPlatform();
      final requirement = _resolveRequirement(
        currentVersion: package.version,
        remote: remote,
      );
      if (!requirement.shouldPrompt) return;

      if (requirement.kind == AppUpdateKind.soft) {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getString(_dismissedVersionKey);
        if (dismissed == requirement.latestVersion) return;
      }

      _pending = requirement;
      notifyListeners();
    } catch (_) {
      // Silencieux : ne bloque jamais le démarrage si l’API est indisponible.
    } finally {
      _checking = false;
    }
  }

  Future<void> dismissSoft() async {
    final current = _pending;
    if (current == null || current.kind == AppUpdateKind.force) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedVersionKey, current.latestVersion);
    _pending = null;
    notifyListeners();
  }

  Future<void> openStore() async {
    final url = _pending?.storeUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<AppVersionInfo> _fetchRemote() async {
    final data = await _api.get('/app/version');
    return AppVersionInfo.fromJson(data);
  }

  AppUpdateRequirement _resolveRequirement({
    required String currentVersion,
    required AppVersionInfo remote,
  }) {
    final latest = remote.latestVersion;
    final min = remote.minVersion;
    final storeUrl = _storeUrl(remote);

    if (latest.isEmpty && min.isEmpty) {
      return AppUpdateRequirement(
        kind: AppUpdateKind.none,
        latestVersion: '',
        storeUrl: storeUrl,
        message: '',
      );
    }

    final belowMin =
        min.isNotEmpty && compareSemver(currentVersion, min) < 0;
    final belowLatest =
        latest.isNotEmpty && compareSemver(currentVersion, latest) < 0;

    if (!belowMin && !belowLatest) {
      return AppUpdateRequirement(
        kind: AppUpdateKind.none,
        latestVersion: latest,
        storeUrl: storeUrl,
        message: '',
      );
    }

    final kind = belowMin ? AppUpdateKind.force : AppUpdateKind.soft;
    return AppUpdateRequirement(
      kind: kind,
      latestVersion: latest.isNotEmpty ? latest : min,
      storeUrl: storeUrl,
      message: remote.message,
    );
  }

  String _storeUrl(AppVersionInfo remote) {
    if (!kIsWeb && Platform.isIOS) {
      final url = remote.iosStoreUrl;
      return url.isNotEmpty ? url : ApiConfig.appStoreUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      final url = remote.androidStoreUrl;
      return url.isNotEmpty ? url : ApiConfig.playStoreUrl;
    }
    return remote.androidStoreUrl.isNotEmpty
        ? remote.androidStoreUrl
        : ApiConfig.playStoreUrl;
  }
}

/// Compare des versions type `1.2.3` (parties numériques seulement).
@visibleForTesting
int compareSemver(String a, String b) {
  List<int> parse(String value) {
    return value
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .map(int.parse)
        .toList();
  }

  final left = parse(a);
  final right = parse(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final ai = i < left.length ? left[i] : 0;
    final bi = i < right.length ? right[i] : 0;
    if (ai != bi) return ai.compareTo(bi);
  }
  return 0;
}
