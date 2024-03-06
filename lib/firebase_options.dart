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
    apiKey: 'AIzaSyDQZa65mwwnfZeLuPmMbNCCYgqwhtUmxK4',
    appId: '1:165482595846:web:205308beb513ae5a91e587',
    messagingSenderId: '165482595846',
    projectId: 'let-s-chat-d4bc5',
    authDomain: 'let-s-chat-d4bc5.firebaseapp.com',
    storageBucket: 'let-s-chat-d4bc5.appspot.com',
    measurementId: 'G-XWFF7945H1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgKJJwioPGu7srqwnAVAp91-vjAwwC7vs',
    appId: '1:165482595846:android:4dac54057a40794e91e587',
    messagingSenderId: '165482595846',
    projectId: 'let-s-chat-d4bc5',
    storageBucket: 'let-s-chat-d4bc5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSH2lu37Oz3HhWjW-di1SF9nbN_ECe_4s',
    appId: '1:165482595846:ios:019199a82b45e36691e587',
    messagingSenderId: '165482595846',
    projectId: 'let-s-chat-d4bc5',
    storageBucket: 'let-s-chat-d4bc5.appspot.com',
    iosBundleId: 'com.example.letsChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBSH2lu37Oz3HhWjW-di1SF9nbN_ECe_4s',
    appId: '1:165482595846:ios:fa69830df67d388f91e587',
    messagingSenderId: '165482595846',
    projectId: 'let-s-chat-d4bc5',
    storageBucket: 'let-s-chat-d4bc5.appspot.com',
    iosBundleId: 'com.example.letsChat.RunnerTests',
  );
}
