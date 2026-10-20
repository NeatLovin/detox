import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/player_stats.dart';

part 'player_stats_repository.g.dart';

class PlayerStatsRepository {
  PlayerStatsRepository(this._client);

  final SupabaseClient _client;

  /// Realtime stream of the user's stats (written by SQL triggers only).
  Stream<PlayerStats> watch(String userId) => _client
      .from('player_stats')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map(
        (rows) => rows.isEmpty
            ? PlayerStats(userId: userId)
            : PlayerStats.fromJson(rows.first),
      );
}

@Riverpod(keepAlive: true)
PlayerStatsRepository playerStatsRepository(Ref ref) =>
    PlayerStatsRepository(ref.watch(supabaseClientProvider));
