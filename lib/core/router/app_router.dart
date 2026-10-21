import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/addictions/presentation/home_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/community/presentation/player_screen.dart';
import '../../features/health_timeline/presentation/timeline_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/cravings/presentation/cravings_journal_screen.dart';
import '../../features/profile/presentation/addiction_form_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/quests/presentation/quests_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/sos/presentation/sos_screen.dart';
import '../session/session_gate.dart';
import '../session/session_providers.dart';
import 'home_shell.dart';
import 'routes.dart';
import 'splash_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final gate = ValueNotifier<SessionGate>(ref.read(sessionGateProvider));
  ref.listen(sessionGateProvider, (_, next) => gate.value = next);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: gate,
    redirect: (context, state) =>
        Routes.redirect(gate.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Full screen, above the bottom navigation.
      GoRoute(
        path: '/sos/:alertId',
        builder: (context, state) => SosScreen(
          alertId: state.pathParameters['alertId']!,
          addictionId: state.uri.queryParameters['addiction'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'timeline/:id',
                    builder: (context, state) =>
                        TimelineScreen(addictionId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.quests,
                builder: (context, state) => const QuestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.community,
                builder: (context, state) => const CommunityScreen(),
                routes: [
                  GoRoute(
                    path: 'players/:id',
                    builder: (context, state) =>
                        PlayerScreen(userId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'cravings',
                    builder: (context, state) => const CravingsJournalScreen(),
                  ),
                  GoRoute(
                    path: 'stats',
                    builder: (context, state) => const StatsScreen(),
                  ),
                  GoRoute(
                    path: 'addictions/new',
                    builder: (context, state) => const AddictionFormScreen(),
                  ),
                  GoRoute(
                    path: 'addictions/:id',
                    builder: (context, state) => AddictionFormScreen(
                      addictionId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    gate.dispose();
    router.dispose();
  });
  return router;
}
