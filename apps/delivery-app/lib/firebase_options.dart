// File generated manually based on google-services.json
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
    apiKey: 'AIzaSyAO-mha02w0KW71CeK-dui_LCvKN6JmMvc',
    appId: '1:460372603542:android:0aa62ac85a4dda7a9f48b7', // Used Android App ID as fallback
    messagingSenderId: '460372603542',
    projectId: 'nilara-83b61',
    authDomain: 'nilara-83b61.firebaseapp.com',
    storageBucket: 'nilara-83b61.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAO-mha02w0KW71CeK-dui_LCvKN6JmMvc',
    appId: '1:460372603542:android:0aa62ac85a4dda7a9f48b7',
    messagingSenderId: '460372603542',
    projectId: 'nilara-83b61',
    storageBucket: 'nilara-83b61.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAO-mha02w0KW71CeK-dui_LCvKN6JmMvc',
    appId: '1:460372603542:ios:fallback',
    messagingSenderId: '460372603542',
    projectId: 'nilara-83b61',
    storageBucket: 'nilara-83b61.firebasestorage.app',
    iosBundleId: 'com.example.blinkitClone',
  );
}
