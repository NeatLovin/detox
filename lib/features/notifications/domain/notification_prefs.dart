/// Reminder hours (Europe/Zurich). Mirrored in SQL by private.send_reminders
/// (test/sql_parity_test.dart).
abstract final class ReminderHours {
  static const pledge = 9;
  static const quests = 20;
}

/// Route to open when a notification is tapped. Only in-app routes are
/// accepted; anything else opens the home screen.
String routeForNotification(Map<String, dynamic> data) {
  const allowed = {'/home', '/community', '/quests'};
  final route = data['route'];
  return route is String && allowed.contains(route) ? route : '/home';
}
