import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/squad_repository.dart';
import '../domain/feed_event.dart';
import '../domain/leaderboard.dart';
import '../domain/squad.dart';

part 'squad_providers.g.dart';

@riverpod
Future<LeaderboardView> leaderboard(Ref ref) async {
  await ref.watch(currentSquadProvider.future);
  final entries = await ref.watch(squadRepositoryProvider).fetchLeaderboard();
  return LeaderboardView.from(entries);
}

@riverpod
Future<List<SquadMember>> squadMembers(Ref ref) async {
  final squad = await ref.watch(currentSquadProvider.future);
  if (squad == null) return const [];
  return ref.watch(squadRepositoryProvider).fetchMembers(squad.id);
}

/// Realtime feed (newest first).
@riverpod
Stream<List<FeedEvent>> squadFeed(Ref ref) async* {
  final squad = await ref.watch(currentSquadProvider.future);
  if (squad == null) {
    yield const [];
    return;
  }
  yield* ref.watch(squadRepositoryProvider).watchFeed(squad.id);
}
