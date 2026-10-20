import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/feed_event.dart';
import '../domain/leaderboard.dart';
import '../domain/player_profile.dart';

part 'community_repository.g.dart';

class CommunityRepository {
  CommunityRepository(this._client);

  final SupabaseClient _client;

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final rows = await _client.rpc<List<dynamic>>('leaderboard');
    return [
      for (final row in rows)
        LeaderboardEntry.fromJson(row as Map<String, dynamic>),
    ];
  }

  /// Throws `profile_private` for someone else's private profile.
  Future<PlayerProfile> fetchPlayer(String userId) async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'player_profile',
      params: {'p_user_id': userId},
    );
    return PlayerProfile.fromJson(json);
  }

  /// Realtime global feed, newest first. RLS hides private players' events.
  Stream<List<FeedEvent>> watchFeed({int limit = 50}) => _client
      .from('feed_events')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .limit(limit)
      .map((rows) => [for (final row in rows) FeedEvent.fromJson(row)]);
}

@Riverpod(keepAlive: true)
CommunityRepository communityRepository(Ref ref) =>
    CommunityRepository(ref.watch(supabaseClientProvider));
