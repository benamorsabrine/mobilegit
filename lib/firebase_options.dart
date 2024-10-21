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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAg6mD-YTt9RrDXAHSp8JcXil2XTas5Zww',
    appId: '1:331048149798:web:d74a994e9e3c484fac17e7',
    messagingSenderId: '331048149798',
    projectId: 'netflix-react-12542',
    authDomain: 'netflix-react-12542.firebaseapp.com',
    storageBucket: 'netflix-react-12542.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHa9om3EptiPFJOPNpqfawCbGvmG3BVR8',
    appId: '1:331048149798:android:f4f8ed7589fb82b2ac17e7',
    messagingSenderId: '331048149798',
    projectId: 'netflix-react-12542',
    storageBucket: 'netflix-react-12542.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3HX0lAJ4xAwjcA5EZZBpQNZ3AbceDyX4',
    appId: '1:331048149798:ios:4fceff7a87e1774bac17e7',
    messagingSenderId: '331048149798',
    projectId: 'netflix-react-12542',
    storageBucket: 'netflix-react-12542.appspot.com',
    iosBundleId: 'com.example.todo',
  );

}