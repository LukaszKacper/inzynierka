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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYm29ERNL-kFcW5XssmgVziSLJL05Fr9M',
    appId: '1:714798005515:android:3066c394b3a4e99141360e',
    messagingSenderId: '714798005515',
    projectId: 'inzynierka-db9e3',
    databaseURL: 'https://inzynierka-db9e3-default-rtdb.firebaseio.com',
    storageBucket: 'inzynierka-db9e3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBOA2185L1BYbqYLWBOv0cjgv0NqL7hCEU',
    appId: '1:714798005515:ios:ab68b38f542f261f41360e',
    messagingSenderId: '714798005515',
    projectId: 'inzynierka-db9e3',
    databaseURL: 'https://inzynierka-db9e3-default-rtdb.firebaseio.com',
    storageBucket: 'inzynierka-db9e3.appspot.com',
    iosBundleId: 'com.example.untitled',
  );
}
