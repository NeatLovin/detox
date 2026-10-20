import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/gamification/data/player_stats_repository.dart';
import '../../features/gamification/domain/player_stats.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/domain/profile.dart';
import 'session_gate.dart';

part 'session_providers.g.dart';

/// Signed-in user id, or null when signed out.
@Riverpod(keepAlive: true)
Stream<String?> authState(Ref ref) =>
    ref.watch(authRepositoryProvider).watchUserId().distinct();

@Riverpod(keepAlive: true)
Future<Profile?> currentProfile(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).fetchProfile(userId);
}

/// Realtime XP / HP / level of the signed-in user.
@riverpod
Stream<PlayerStats> playerStats(Ref ref) async* {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return;
  yield* ref.watch(playerStatsRepositoryProvider).watch(userId);
}

@Riverpod(keepAlive: true)
SessionGate sessionGate(Ref ref) => computeSessionGate(
  userId: ref.watch(authStateProvider),
  profile: ref.watch(currentProfileProvider),
);
