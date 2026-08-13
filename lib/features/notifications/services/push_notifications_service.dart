import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:linkflutter/features/notifications/services/notifications_api_service.dart';
import 'package:linkflutter/firebase_options.dart';

const _androidChannel = AndroidNotificationChannel(
  'dropone_default',
  'DropOne',
  description: 'Notifications DropOne',
  importance: Importance.high,
);

Future<bool> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (error, stack) {
    debugPrint('Firebase.initializeApp failed: $error\n$stack');
    return false;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebaseInitialized();
}

class PushNotificationsService {
  PushNotificationsService(this._api);

  final NotificationsApiService _api;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _started = false;
  bool _localReady = false;
  void Function(RemoteMessage message)? onForegroundMessage;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final ready = await ensureFirebaseInitialized();
      if (!ready) {
        _started = false;
        return;
      }

      await _initLocalNotifications();

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Notifications: permission refusée');
        return;
      }

      var canSyncToken = true;
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        final hasApns = await _waitForApnsToken(messaging);
        if (!hasApns) {
          canSyncToken = false;
          debugPrint(
            'Notifications: pas de token APNs. '
            'Le push système ne marche pas sur simulateur iOS — '
            'utilise un iPhone réel. L’inbox in-app reste disponible.',
          );
        }
      }

      if (canSyncToken) {
        await _syncToken(messaging);
      }
      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
        _currentToken = token;
        await _register(token);
      });

      _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
        onForegroundMessage?.call(message);
      });
    } catch (error, stack) {
      _started = false;
      debugPrint('PushNotificationsService.start failed: $error\n$stack');
    }
  }

  Future<void> stop() async {
    final token = _currentToken;
    _currentToken = null;
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _started = false;

    if (token == null || token.isEmpty) return;
    try {
      await _api.unregisterPushToken(token);
    } catch (_) {
      // Ignore logout cleanup errors.
    }
  }

  Future<void> _initLocalNotifications() async {
    if (_localReady) return;
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_androidChannel);
    await android?.requestNotificationsPermission();
    _localReady = true;
  }

  Future<bool> _waitForApnsToken(FirebaseMessaging messaging) async {
    for (var i = 0; i < 12; i++) {
      final token = await messaging.getAPNSToken();
      if (token != null && token.isNotEmpty) return true;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    return false;
  }

  Future<void> _syncToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken().timeout(
        const Duration(seconds: 8),
      );
      if (token == null || token.isEmpty) {
        debugPrint('Notifications: getToken() a renvoyé null');
        return;
      }
      debugPrint('Notifications: token FCM enregistré (${token.length} car.)');
      _currentToken = token;
      await _register(token);
    } catch (error) {
      debugPrint('Notifications: getToken() a échoué: $error');
    }
  }

  Future<void> _register(String token) async {
    final platform = Platform.isIOS
        ? 'IOS'
        : Platform.isAndroid
            ? 'ANDROID'
            : 'WEB';
    try {
      await _api.registerPushToken(token: token, platform: platform);
    } catch (error) {
      debugPrint('registerPushToken failed: $error');
    }
  }
}
