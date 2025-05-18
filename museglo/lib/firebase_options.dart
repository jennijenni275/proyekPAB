import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyB96tagK_whoK2dvIk5zgLDdfni3DhjlTg',
    appId: '1:248437693697:web:2b86b767d743a294c2cf00',
    messagingSenderId: '248437693697',
    projectId: 'museglo-app',
    authDomain: 'museglo-app.firebaseapp.com',
    databaseURL: 'https://museglo-app-default-rtdb.firebaseio.com',
    storageBucket: 'museglo-app.firebasestorage.app',
    measurementId: 'G-J0DQ6JF3QP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdkFlMZI4B4LasrEUIH6jT5uGdctw53XI',
    appId: '1:248437693697:android:12bf3b53a42a1c60c2cf00',
    messagingSenderId: '248437693697',
    projectId: 'museglo-app',
    databaseURL: 'https://museglo-app-default-rtdb.firebaseio.com',
    storageBucket: 'museglo-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2k19ldwh9KPBrfImJNUpfKBnRVFB-xGQ',
    appId: '1:248437693697:ios:deca3f2d653276a4c2cf00',
    messagingSenderId: '248437693697',
    projectId: 'museglo-app',
    databaseURL: 'https://museglo-app-default-rtdb.firebaseio.com',
    storageBucket: 'museglo-app.firebasestorage.app',
    iosBundleId: 'com.example.museglo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2k19ldwh9KPBrfImJNUpfKBnRVFB-xGQ',
    appId: '1:248437693697:ios:deca3f2d653276a4c2cf00',
    messagingSenderId: '248437693697',
    projectId: 'museglo-app',
    databaseURL: 'https://museglo-app-default-rtdb.firebaseio.com',
    storageBucket: 'museglo-app.firebasestorage.app',
    iosBundleId: 'com.example.museglo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB96tagK_whoK2dvIk5zgLDdfni3DhjlTg',
    appId: '1:248437693697:web:403a0f8743437145c2cf00',
    messagingSenderId: '248437693697',
    projectId: 'museglo-app',
    authDomain: 'museglo-app.firebaseapp.com',
    databaseURL: 'https://museglo-app-default-rtdb.firebaseio.com',
    storageBucket: 'museglo-app.firebasestorage.app',
    measurementId: 'G-B04QFMTRBG',
  );

}