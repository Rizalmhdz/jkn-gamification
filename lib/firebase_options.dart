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
    apiKey: 'AIzaSyCH7C0c7c2HxA5Ub5ac5Itr_SwIngxWRh0',
    appId: '1:129943866617:web:6be2bb01e3fd24458d2628',
    messagingSenderId: '129943866617',
    projectId: 'gamification-jkn-mobile',
    authDomain: 'gamification-jkn-mobile.firebaseapp.com',
    databaseURL: 'https://gamification-jkn-mobile-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gamification-jkn-mobile.appspot.com',
    measurementId: 'G-S5XECGQEG1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgOxb2KEQfGUBjHJWQGqePmW4trbUqbPI',
    appId: '1:129943866617:android:3a89253813fbef268d2628',
    messagingSenderId: '129943866617',
    projectId: 'gamification-jkn-mobile',
    databaseURL: 'https://gamification-jkn-mobile-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gamification-jkn-mobile.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqhhtvQmRPkhmCna-INkNdjdKL-NV945c',
    appId: '1:129943866617:ios:d6bd96637d70a8818d2628',
    messagingSenderId: '129943866617',
    projectId: 'gamification-jkn-mobile',
    databaseURL: 'https://gamification-jkn-mobile-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gamification-jkn-mobile.appspot.com',
    iosBundleId: 'com.example.jknGamification',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCqhhtvQmRPkhmCna-INkNdjdKL-NV945c',
    appId: '1:129943866617:ios:d6bd96637d70a8818d2628',
    messagingSenderId: '129943866617',
    projectId: 'gamification-jkn-mobile',
    databaseURL: 'https://gamification-jkn-mobile-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gamification-jkn-mobile.appspot.com',
    iosBundleId: 'com.example.jknGamification',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCH7C0c7c2HxA5Ub5ac5Itr_SwIngxWRh0',
    appId: '1:129943866617:web:721e9a4791e3178b8d2628',
    messagingSenderId: '129943866617',
    projectId: 'gamification-jkn-mobile',
    authDomain: 'gamification-jkn-mobile.firebaseapp.com',
    databaseURL: 'https://gamification-jkn-mobile-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'gamification-jkn-mobile.appspot.com',
    measurementId: 'G-V0JL87MD46',
  );
}