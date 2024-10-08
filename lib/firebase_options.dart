// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAXKxPfxTgApaDCc4xWr2WpDyTP0U-3s_U',
    appId: '1:902740436533:web:25141f917291b4097b337c',
    messagingSenderId: '902740436533',
    projectId: 'geminichat-839dd',
    authDomain: 'geminichat-839dd.firebaseapp.com',
    storageBucket: 'geminichat-839dd.appspot.com',
    measurementId: 'G-CKLVZLRZ81',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAMW9BBPjy-ReHUkbkn9nJEVTLYbrWmfA',
    appId: '1:902740436533:android:1eb7da0c4637d1777b337c',
    messagingSenderId: '902740436533',
    projectId: 'geminichat-839dd',
    storageBucket: 'geminichat-839dd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrq3TrnmFQskMcO3fXtaaEMhIw5D_sDfM',
    appId: '1:902740436533:ios:7826a8ac3bd5ce7c7b337c',
    messagingSenderId: '902740436533',
    projectId: 'geminichat-839dd',
    storageBucket: 'geminichat-839dd.appspot.com',
    iosBundleId: 'com.example.geminiChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBrq3TrnmFQskMcO3fXtaaEMhIw5D_sDfM',
    appId: '1:902740436533:ios:7826a8ac3bd5ce7c7b337c',
    messagingSenderId: '902740436533',
    projectId: 'geminichat-839dd',
    storageBucket: 'geminichat-839dd.appspot.com',
    iosBundleId: 'com.example.geminiChat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAXKxPfxTgApaDCc4xWr2WpDyTP0U-3s_U',
    appId: '1:902740436533:web:4d4d5be9bec0b62b7b337c',
    messagingSenderId: '902740436533',
    projectId: 'geminichat-839dd',
    authDomain: 'geminichat-839dd.firebaseapp.com',
    storageBucket: 'geminichat-839dd.appspot.com',
    measurementId: 'G-MXCLD7242J',
  );
}
