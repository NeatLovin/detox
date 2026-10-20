import 'dart:io';

import 'package:detox/features/notifications/domain/notification_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a tapped notification only opens known in-app routes', () {
    expect(routeForNotification({'route': '/community'}), '/community');
    expect(routeForNotification({'route': '/quests'}), '/quests');
    expect(routeForNotification({'route': 'https://evil.example'}), '/home');
    expect(routeForNotification({'route': 42}), '/home');
    expect(routeForNotification({}), '/home');
  });

  test('reminder hours: Dart == SQL private.send_reminders', () {
    final sql = File('supabase/migrations/20261021090000_push.sql').readAsStringSync();
    expect(sql, contains('if v_hour = ${ReminderHours.pledge} and'));
    expect(sql, contains('if v_hour = ${ReminderHours.quests} and'));
  });

  test('Android notification channel id matches the Edge Function', () {
    final kotlin = File('android/app/src/main/kotlin/ch/neatlovin/detox/MainActivity.kt').readAsStringSync();
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final function = File('supabase/functions/push/index.ts').readAsStringSync();
    expect(kotlin, contains('CHANNEL_ID = "detox"'));
    expect(manifest, contains('android:value="detox"'));
    expect(function, contains('channel_id: "detox"'));
  });
}
