import '../session/session_gate.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const squadSetup = '/squad-setup';
  static const home = '/home';
  static const quests = '/quests';
  static const squad = '/squad';
  static const squadSettings = '/squad/settings';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const newAddiction = '/profile/addictions/new';
  static String editAddiction(String id) => '/profile/addictions/$id';
  static const cravings = '/profile/cravings';
  static String sos(String alertId, String addictionId) =>
      '/sos/$alertId?addiction=$addictionId';

  static const _gateRoutes = {splash, auth, onboarding, squadSetup};

  /// Pure redirect logic, unit tested.
  static String? redirect(SessionGate gate, String location) {
    String? goTo(String target) => location == target ? null : target;
    return switch (gate) {
      SessionGate.loading || SessionGate.error => goTo(splash),
      SessionGate.signedOut => goTo(auth),
      SessionGate.needsProfile => goTo(onboarding),
      SessionGate.needsSquad => goTo(squadSetup),
      SessionGate.ready => _gateRoutes.contains(location) ? home : null,
    };
  }
}
