import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:linkflutter/features/notifications/services/notifications_api_service.dart';
import 'package:linkflutter/firebase_options.dart';

const _appBadgeChannel = MethodChannel('com.mega.dropone/app_badge');

const _androidChannel = AndroidNotificationChannel(
  'dropone_default',
  'DropOne',
  description: 'Notifications DropOne',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
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

      if (Platform.isIOS) {
        // Bannière + son gérés en local (plus fiable que la présentation système).
        await messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: false,
        );
        final hasApns = await _waitForApnsToken(messaging);
        if (!hasApns) {
          debugPrint(
            'Notifications: pas de token APNs après l’attente initiale. '
            'Nouvel essai prévu. Sur simulateur iOS le push système ne marche pas.',
          );
        }
      }

      await _syncToken(messaging);
      // Sur iPhone, le token APNs peut arriver après le démarrage.
      if (Platform.isIOS && (_currentToken == null || _currentToken!.isEmpty)) {
        unawaited(_retryIosTokenSync(messaging));
      }

      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
        _currentToken = token;
        await _register(token);
      });

      _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
        onForegroundMessage?.call(message);
        unawaited(_showForegroundNotification(message));
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
    await syncAppIconBadge(0);

    if (token == null || token.isEmpty) return;
    try {
      await _api.unregisterPushToken(token);
    } catch (_) {
      // Ignore logout cleanup errors.
    }
  }

  /// Met à jour le badge de l’icône (nombre de non lus). 0 = masqué.
  Future<void> syncAppIconBadge(int unreadCount) async {
    final count = unreadCount < 0 ? 0 : unreadCount;
    try {
      if (Platform.isIOS) {
        await _appBadgeChannel.invokeMethod<void>('setBadge', count);
        return;
      }
      if (Platform.isAndroid) {
        if (!_localReady) await _initLocalNotifications();
        // Sur Android le badge suit souvent les notifs actives ; on aligne via
        // une mise à jour silencieuse puis on annule si tout est lu.
        if (count <= 0) {
          await _local.cancelAll();
          return;
        }
      }
    } catch (error) {
      debugPrint('syncAppIconBadge failed: $error');
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
    for (var i = 0; i < 30; i++) {
      final token = await messaging.getAPNSToken();
      if (token != null && token.isNotEmpty) return true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  Future<void> _retryIosTokenSync(FirebaseMessaging messaging) async {
    for (var attempt = 0; attempt < 6; attempt++) {
      await Future<void>.delayed(Duration(seconds: 2 + attempt));
      if (!_started) return;
      if (_currentToken != null && _currentToken!.isNotEmpty) return;
      final hasApns = await _waitForApnsToken(messaging);
      if (!hasApns) continue;
      await _syncToken(messaging);
      if (_currentToken != null && _currentToken!.isNotEmpty) return;
    }
    debugPrint(
      'Notifications: impossible d’obtenir un token FCM iOS. '
      'Vérifier Push Notifications + clé APNs Firebase pour com.mega.dropone2.',
    );
  }

  Future<void> _syncToken(FirebaseMessaging messaging) async {
    try {
      if (Platform.isIOS) {
        final apns = await messaging.getAPNSToken();
        if (apns == null || apns.isEmpty) {
          debugPrint('Notifications: getToken() reporté (APNs absent)');
          return;
        }
      }
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

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localReady) await _initLocalNotifications();

    final title = (message.notification?.title ?? message.data['title'] ?? '')
        .trim();
    final body =
        (message.notification?.body ?? message.data['body'] ?? '').trim();
    if (title.isEmpty && body.isEmpty) return;

    try {
      await _local.show(
        message.messageId?.hashCode ??
            Object.hash(title, body, DateTime.now().millisecondsSinceEpoch),
        title.isEmpty ? 'DropOne' : title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: _badgeFromMessage(message),
          ),
        ),
      );
    } catch (error) {
      debugPrint('Notifications: affichage local échoué: $error');
    }
  }

  int? _badgeFromMessage(RemoteMessage message) {
    final raw = message.data['unreadCount']?.toString();
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }
}
