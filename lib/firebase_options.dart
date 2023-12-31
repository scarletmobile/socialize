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
    apiKey: 'AIzaSyCTWb_K676F8EmCkKdyyIH1rxpEcgVinEI',
    appId: '1:901700965107:web:953bad96b5bab90b5a1d86',
    messagingSenderId: '901700965107',
    projectId: 'soXialz-ba685',
    authDomain: 'soXialz-ba685.firebaseapp.com',
    storageBucket: 'soXialz-ba685.appspot.com',
    measurementId: 'G-S098C2D7Z7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC00RhX8BzUYzbZd4ZR8uAEz9SSG4YENOg',
    appId: '1:901700965107:android:e9035d02813d34ce5a1d86',
    messagingSenderId: '901700965107',
    projectId: 'soXialz-ba685',
    storageBucket: 'soXialz-ba685.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5BrwzA0jb0M3gqsjY9BOMZWVLLscLIxg',
    appId: '1:901700965107:ios:256b65959a6b778b5a1d86',
    messagingSenderId: '901700965107',
    projectId: 'soXialz-ba685',
    storageBucket: 'soXialz-ba685.appspot.com',
    androidClientId: '901700965107-kjkl43b4jggjlf4b6dvmcpb07fqcie4m.apps.googleusercontent.com',
    iosClientId: '901700965107-aq3nqci3bcv3nnq98c6qlon99o5cu9lu.apps.googleusercontent.com',
    iosBundleId: 'com.app.soXialz',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5BrwzA0jb0M3gqsjY9BOMZWVLLscLIxg',
    appId: '1:901700965107:ios:7bd8468a4a84c8905a1d86',
    messagingSenderId: '901700965107',
    projectId: 'soXialz-ba685',
    storageBucket: 'soXialz-ba685.appspot.com',
    androidClientId: '901700965107-kjkl43b4jggjlf4b6dvmcpb07fqcie4m.apps.googleusercontent.com',
    iosClientId: '901700965107-pofli4euh5tm51hpibftcn5aplpl200e.apps.googleusercontent.com',
    iosBundleId: 'com.example.soXialz',
  );
}
