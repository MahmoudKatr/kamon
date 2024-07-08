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
    apiKey: 'AIzaSyB7ab9i6AiSzLvRmUXGLKc_OdAUcl23o1g',
    appId: '1:149765186492:web:3bda0fef75d0891dae81b9',
    messagingSenderId: '149765186492',
    projectId: 'otp-otp-481e1',
    authDomain: 'otp-otp-481e1.firebaseapp.com',
    storageBucket: 'otp-otp-481e1.appspot.com',
    measurementId: 'G-35E2F9G7WX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZid56jpImiH5XmZX6Z5c3z5hUgxChn4M',
    appId: '1:149765186492:android:f82c70d5ebfb41e8ae81b9',
    messagingSenderId: '149765186492',
    projectId: 'otp-otp-481e1',
    storageBucket: 'otp-otp-481e1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5iez8XvOBCgRgmP4C-uliUa7LJop_G64',
    appId: '1:149765186492:ios:5c322cd554ac4015ae81b9',
    messagingSenderId: '149765186492',
    projectId: 'otp-otp-481e1',
    storageBucket: 'otp-otp-481e1.appspot.com',
    iosBundleId: 'com.example.kamon',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5iez8XvOBCgRgmP4C-uliUa7LJop_G64',
    appId: '1:149765186492:ios:5c322cd554ac4015ae81b9',
    messagingSenderId: '149765186492',
    projectId: 'otp-otp-481e1',
    storageBucket: 'otp-otp-481e1.appspot.com',
    iosBundleId: 'com.example.kamon',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7ab9i6AiSzLvRmUXGLKc_OdAUcl23o1g',
    appId: '1:149765186492:web:8f020c130aea2435ae81b9',
    messagingSenderId: '149765186492',
    projectId: 'otp-otp-481e1',
    authDomain: 'otp-otp-481e1.firebaseapp.com',
    storageBucket: 'otp-otp-481e1.appspot.com',
    measurementId: 'G-FW6G360JT3',
  );
}
