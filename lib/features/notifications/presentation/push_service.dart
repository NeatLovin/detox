import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_options.dart';
import '../../../core/session/session_providers.dart';
import '../data/push_repository.dart';
import '../domain/notification_prefs.dart';

part 'push_service.g.dart';

/// True once Firebase is ready. Push is optional: any failure leaves the app
/// fully usable, only without notifications.
Future<bool> initFirebase() async {
  if (defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: androidFirebaseOptions);
    }
    return true;
  } catch (error) {
    debugPrint('Firebase init failed: $error');
    return false;
  }
}

/// Routes opened from tapped notifications, consumed by the home shell.
@Riverpod(keepAlive: true)
class PendingNotificationRoute extends _$PendingNotificationRoute {
  @override
  String? build() => null;

  void set(String? route) => state = route;
}

/// Registers this device for the signed-in user and keeps the token fresh.
/// Watched by the home shell: runs once per signed-in session.
@Riverpod(keepAlive: true)
Future<void> pushSetup(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null || !await initFirebase()) return;

  final messaging = FirebaseMessaging.instance;
  final repo = ref.read(pushRepositoryProvider);

  final settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.denied) return;

  final token = await messaging.getToken();
  if (token != null) await repo.register(token);

  final refresh = messaging.onTokenRefresh.listen((t) => unawaited(repo.register(t)));
  final opened = FirebaseMessaging.onMessageOpenedApp.listen((message) {
    ref.read(pendingNotificationRouteProvider.notifier).set(routeForNotification(message.data));
  });
  final initial = await messaging.getInitialMessage();
  if (initial != null) {
    ref.read(pendingNotificationRouteProvider.notifier).set(routeForNotification(initial.data));
  }

  ref.onDispose(() {
    refresh.cancel();
    opened.cancel();
  });
}

/// Called before signing out so the device stops receiving this user's pushes.
Future<void> unregisterThisDevice(PushRepository repo) async {
  try {
    if (Firebase.apps.isEmpty) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await repo.unregister(token);
  } catch (error) {
    debugPrint('Push unregister failed: $error');
  }
}
