import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/community_repository.dart';
import '../domain/feed_event.dart';
import '../domain/feed_reaction.dart';
import '../domain/leaderboard.dart';
import '../domain/leaderboard_week.dart';
import '../domain/player_profile.dart';

part 'community_providers.g.dart';

@riverpod
Future<LeaderboardView> leaderboard(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return LeaderboardView.from(const []);
  final entries = await ref.watch(communityRepositoryProvider).fetchLeaderboard();
  return LeaderboardView.from(entries);
}

/// Realtime global feed (newest first).
@riverpod
Stream<List<FeedEvent>> communityFeed(Ref ref) async* {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) {
    yield const [];
    return;
  }
  yield* ref.watch(communityRepositoryProvider).watchFeed();
}

@riverpod
Future<PlayerProfile> playerProfile(Ref ref, String userId) =>
    ref.watch(communityRepositoryProvider).fetchPlayer(userId);

@riverpod
Future<LeaderboardView> weekLeaderboard(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return LeaderboardView.from(const []);
  final entries = await ref
      .watch(communityRepositoryProvider)
      .fetchWeekLeaderboard();
  return LeaderboardView.from(entries);
}

/// Leaderboard tab picked on the community screen (the week by default).
@riverpod
class SelectedLeaderboard extends _$SelectedLeaderboard {
  @override
  LeaderboardScope build() => LeaderboardScope.week;

  void select(LeaderboardScope scope) => state = scope;
}

/// Realtime reactions, grouped by feed event.
@riverpod
Stream<Map<String, ReactionSummary>> feedReactions(Ref ref) async* {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) {
    yield const {};
    return;
  }
  yield* ref
      .watch(communityRepositoryProvider)
      .watchReactions()
      .map((reactions) => summarizeReactions(reactions, userId));
}
