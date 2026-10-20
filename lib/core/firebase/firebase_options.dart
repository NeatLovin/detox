import 'package:firebase_core/firebase_core.dart';

/// Firebase client configuration (from google-services.json, project
/// detox-46). These values are public by design: they identify the app, they
/// do not grant access. Used instead of the google-services Gradle plugin.
const androidFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyC_q3VkrQIIby6jrxE3xeSIjYD6krgFhaU',
  appId: '1:318222053672:android:466fe2452ab513e96aa01d',
  messagingSenderId: '318222053672',
  projectId: 'detox-46',
  storageBucket: 'detox-46.firebasestorage.app',
);
