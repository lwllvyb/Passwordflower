// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA6GTTxw3RYFbcR9m1nAL6PexgKsD_gF8Q',
    appId: '1:1091545420924:web:3cc61f28a8926f061825f9',
    messagingSenderId: '1091545420924',
    projectId: 'protect-c29a0',
    authDomain: 'protect-c29a0.firebaseapp.com',
    databaseURL: 'https://protect-c29a0-default-rtdb.firebaseio.com',
    storageBucket: 'protect-c29a0.appspot.com',
    measurementId: 'G-S5Z8H2Z7K7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD68aFj6Td5vJbY7mjzC4KA-yCzNGWHrnM',
    appId: '1:1091545420924:android:3e27a6f9b49af3371825f9',
    messagingSenderId: '1091545420924',
    projectId: 'protect-c29a0',
    databaseURL: 'https://protect-c29a0-default-rtdb.firebaseio.com',
    storageBucket: 'protect-c29a0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC1JOKrk_kZ1V7XKbyMw58pSilSTVKmlCo',
    appId: '1:1091545420924:ios:5f1490600c2f08691825f9',
    messagingSenderId: '1091545420924',
    projectId: 'protect-c29a0',
    databaseURL: 'https://protect-c29a0-default-rtdb.firebaseio.com',
    storageBucket: 'protect-c29a0.appspot.com',
    iosBundleId: 'com.example.florakey',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC1JOKrk_kZ1V7XKbyMw58pSilSTVKmlCo',
    appId: '1:1091545420924:ios:a5abaf5d762a0aec1825f9',
    messagingSenderId: '1091545420924',
    projectId: 'protect-c29a0',
    databaseURL: 'https://protect-c29a0-default-rtdb.firebaseio.com',
    storageBucket: 'protect-c29a0.appspot.com',
    iosBundleId: 'com.example.florakey.RunnerTests',
  );
}
