import '../session/session_gate.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static String timeline(String addictionId) => '/home/timeline/$addictionId';
  static const quests = '/quests';
  static const community = '/community';
  static String player(String userId) => '/community/players/$userId';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const newAddiction = '/profile/addictions/new';
  static String editAddiction(String id) => '/profile/addictions/$id';
  static const cravings = '/profile/cravings';
  static const stats = '/profile/stats';
  static String sos(String alertId, String addictionId) =>
      '/sos/$alertId?addiction=$addictionId';

  static const _gateRoutes = {splash, auth, onboarding};

  /// Pure redirect logic, unit tested.
  static String? redirect(SessionGate gate, String location) {
    String? goTo(String target) => location == target ? null : target;
    return switch (gate) {
      SessionGate.loading || SessionGate.error => goTo(splash),
      SessionGate.signedOut => goTo(auth),
      SessionGate.needsProfile => goTo(onboarding),
      SessionGate.ready => _gateRoutes.contains(location) ? home : null,
    };
  }
}
