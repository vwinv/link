import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web n’est pas configuré pour DropOne.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase n’est pas configuré pour ${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVIxuz_TrX2tbfgx7KW9wvYflT5nsx2lk',
    appId: '1:880526404169:android:88837616a50aaacb78ed98',
    messagingSenderId: '880526404169',
    projectId: 'dropone-6c91e',
    storageBucket: 'dropone-6c91e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAC-Kx4_-Op8r6KP_Ot6XPix0cUvhg1_bY',
    appId: '1:880526404169:ios:20a0a0e178b08b3978ed98',
    messagingSenderId: '880526404169',
    projectId: 'dropone-6c91e',
    storageBucket: 'dropone-6c91e.firebasestorage.app',
    iosBundleId: 'com.mega.dropone2',
  );
}
