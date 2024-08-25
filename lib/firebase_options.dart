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
    apiKey: 'AIzaSyDYruxNSEKW0LUdSmwY2wNIPR4S1u5m65c',
    appId: '1:249891496822:web:0fefcd6e38606c58e99057',
    messagingSenderId: '249891496822',
    projectId: 'learn-firebase-project-61e20',
    authDomain: 'learn-firebase-project-61e20.firebaseapp.com',
    databaseURL: 'https://learn-firebase-project-61e20-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'learn-firebase-project-61e20.appspot.com',
    measurementId: 'G-KYCED3DWSL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAt-A3ComHfA7huzG5f3UnqrysWXo2ynPM',
    appId: '1:249891496822:android:4a987baa39b3c242e99057',
    messagingSenderId: '249891496822',
    projectId: 'learn-firebase-project-61e20',
    databaseURL: 'https://learn-firebase-project-61e20-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'learn-firebase-project-61e20.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQyMO2nNyvsBbMGkfpYM3_6LOceNHyVgI',
    appId: '1:249891496822:ios:bd14a6c01a727ec6e99057',
    messagingSenderId: '249891496822',
    projectId: 'learn-firebase-project-61e20',
    databaseURL: 'https://learn-firebase-project-61e20-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'learn-firebase-project-61e20.appspot.com',
    androidClientId: '249891496822-cmnq3kuf4385ggl3fr4esrmgltgbkq9u.apps.googleusercontent.com',
    iosClientId: '249891496822-4r4952rn01ejrvtujskaulbrd3brfvo0.apps.googleusercontent.com',
    iosBundleId: 'com.example.instaProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQyMO2nNyvsBbMGkfpYM3_6LOceNHyVgI',
    appId: '1:249891496822:ios:bd14a6c01a727ec6e99057',
    messagingSenderId: '249891496822',
    projectId: 'learn-firebase-project-61e20',
    databaseURL: 'https://learn-firebase-project-61e20-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'learn-firebase-project-61e20.appspot.com',
    androidClientId: '249891496822-cmnq3kuf4385ggl3fr4esrmgltgbkq9u.apps.googleusercontent.com',
    iosClientId: '249891496822-4r4952rn01ejrvtujskaulbrd3brfvo0.apps.googleusercontent.com',
    iosBundleId: 'com.example.instaProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBfwWzN5SO9ZyLxtp6IBdxDBYw-d8Cd38',
    appId: '1:249891496822:web:123f677ca0ccd413e99057',
    messagingSenderId: '249891496822',
    projectId: 'learn-firebase-project-61e20',
    authDomain: 'learn-firebase-project-61e20.firebaseapp.com',
    databaseURL: 'https://learn-firebase-project-61e20-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'learn-firebase-project-61e20.appspot.com',
    measurementId: 'G-T71HYN8DXQ',
  );
}
