import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5lYJWC_2tjxNBi7UobZSUhYusYeQGjuE',
    appId: '1:630617228509:android:a52c3a9d8b53857acfc734',
    messagingSenderId: '630617228509',
    projectId: 'myday-study-dev',
    storageBucket: 'myday-study-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8UodhqSG0nmEkEkfHYj9TazjDryjMf3c',
    appId: '1:630617228509:ios:af1bd9f340213d9ccfc734',
    messagingSenderId: '630617228509',
    projectId: 'myday-study-dev',
    storageBucket: 'myday-study-dev.firebasestorage.app',
    iosBundleId: 'com.myday.myday',
  );
}
