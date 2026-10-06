import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] configured for Firebase project:
/// Project ID: donar-app-bc8bc
/// Project Number: 1045088821221
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDNf17zKwEetx8s1a0AsFs3kF-FMVMnQPw',
    appId: '1:1045088821221:web:4682ee957796639dfc590c',
    messagingSenderId: '1045088821221',
    projectId: 'donar-app-bc8bc',
    authDomain: 'donar-app-bc8bc.firebaseapp.com',
    storageBucket: 'donar-app-bc8bc.firebasestorage.app',
    measurementId: 'G-QRZ6SF02LR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwg8Gn-SpbEnrALwYRGNzUdZHh1pSoc98',
    appId: '1:1045088821221:android:1281a4ea4994bb00fc590c',
    messagingSenderId: '1045088821221',
    projectId: 'donar-app-bc8bc',
    storageBucket: 'donar-app-bc8bc.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDwg8Gn-SpbEnrALwYRGNzUdZHh1pSoc98',
    appId: '1:1045088821221:ios:1281a4ea4994bb00fc590c',
    messagingSenderId: '1045088821221',
    projectId: 'donar-app-bc8bc',
    storageBucket: 'donar-app-bc8bc.firebasestorage.app',
    iosBundleId: 'com.lifedrop.lifedrop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDwg8Gn-SpbEnrALwYRGNzUdZHh1pSoc98',
    appId: '1:1045088821221:ios:1281a4ea4994bb00fc590c',
    messagingSenderId: '1045088821221',
    projectId: 'donar-app-bc8bc',
    storageBucket: 'donar-app-bc8bc.firebasestorage.app',
    iosBundleId: 'com.lifedrop.lifedrop',
  );
}
