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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1iGB7ywmjeR_G__9fRvyfmxIARbDGEmQ',
    appId: '1:83395238285:android:6d6504866219ffba4dc5c4',
    messagingSenderId: '83395238285',
    projectId: 'ring-social-app',
    storageBucket: 'ring-social-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIYUUknI9wQ0Bo25G6yRX6HTdBBFp56jg',
    appId: '1:83395238285:ios:4f0c4fe3a3dd5e0c4dc5c4',
    messagingSenderId: '83395238285',
    projectId: 'ring-social-app',
    storageBucket: 'ring-social-app.appspot.com',
    iosBundleId: 'com.example.socialapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIYUUknI9wQ0Bo25G6yRX6HTdBBFp56jg',
    appId: '1:83395238285:ios:4f0c4fe3a3dd5e0c4dc5c4',
    messagingSenderId: '83395238285',
    projectId: 'ring-social-app',
    storageBucket: 'ring-social-app.appspot.com',
    iosBundleId: 'com.example.socialapp',
  );
}
