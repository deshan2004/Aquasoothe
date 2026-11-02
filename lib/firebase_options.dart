// File generated for AquaSoothe Firebase integration
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARxhBcz3t-7F6-WH0cN_A2XTUsV33zmXc',
    appId: '1:1054170301134:web:8a639d4f19e334564cc69f',
    messagingSenderId: '1054170301134',
    projectId: 'aquasoothe-ca290',
    storageBucket: 'aquasoothe-ca290.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwN2HZ8L0pT0t0hpifLt64FShXz2NUjiE',
    appId: '1:1054170301134:android:4bc59461ff2d59554cc69f',
    messagingSenderId: '1054170301134',
    projectId: 'aquasoothe-ca290',
    storageBucket: 'aquasoothe-ca290.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyARxhBcz3t-7F6-WH0cN_A2XTUsV33zmXc',
    appId: '1:1054170301134:ios:8a639d4f19e334564cc69f',
    messagingSenderId: '1054170301134',
    projectId: 'aquasoothe-ca290',
    storageBucket: 'aquasoothe-ca290.firebasestorage.app',
    iosBundleId: 'com.aquasoothe.aquasoothe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyARxhBcz3t-7F6-WH0cN_A2XTUsV33zmXc',
    appId: '1:1054170301134:ios:8a639d4f19e334564cc69f',
    messagingSenderId: '1054170301134',
    projectId: 'aquasoothe-ca290',
    storageBucket: 'aquasoothe-ca290.firebasestorage.app',
    iosBundleId: 'com.aquasoothe.aquasoothe',
  );
}
