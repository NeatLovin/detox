import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/feed_event.dart';
import '../domain/squad.dart';
import '../domain/squad_rules.dart';

part 'squad_repository.g.dart';

class SquadRepository {
  SquadRepository(this._client);

  final SupabaseClient _client;

  Future<Squad?> fetchSquadOf(String userId) async {
    final row = await _client
        .from('squad_members')
        .select('squads(*)')
        .eq('user_id', userId)
        .maybeSingle();
    final squad = row?['squads'];
    return squad == null ? null : Squad.fromJson(squad as Map<String, dynamic>);
  }

  Future<Squad> createSquad(String name) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'create_squad',
      params: {'name': name.trim()},
    );
    return Squad.fromJson(row);
  }

  Future<Squad> joinSquad(String code) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'join_squad',
      params: {'code': SquadRules.normalizeInviteCode(code)},
    );
    return Squad.fromJson(row);
  }

  Future<void> leaveSquad() => _client.rpc<void>('leave_squad');

  Future<List<SquadMember>> fetchMembers(String squadId) async {
    final rows = await _client
        .from('squad_members')
        .select('user_id, role, joined_at, profiles(username, avatar_emoji)')
        .eq('squad_id', squadId)
        .order('joined_at');
    return [
      for (final row in rows)
        SquadMember(
          userId: row['user_id'] as String,
          username: (row['profiles'] as Map?)?['username'] as String? ?? '?',
          avatarEmoji:
              (row['profiles'] as Map?)?['avatar_emoji'] as String? ?? '👤',
          role: row['role'] == 'owner' ? SquadRole.owner : SquadRole.member,
          joinedAt: DateTime.parse(row['joined_at'] as String),
        ),
    ];
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final rows = await _client.rpc<List<dynamic>>('squad_leaderboard');
    return [
      for (final row in rows)
        LeaderboardEntry.fromJson(row as Map<String, dynamic>),
    ];
  }

  /// Realtime feed of the squad, newest first.
  Stream<List<FeedEvent>> watchFeed(String squadId, {int limit = 50}) => _client
      .from('feed_events')
      .stream(primaryKey: ['id'])
      .eq('squad_id', squadId)
      .order('created_at')
      .limit(limit)
      .map((rows) => [for (final row in rows) FeedEvent.fromJson(row)]);
}

@Riverpod(keepAlive: true)
SquadRepository squadRepository(Ref ref) =>
    SquadRepository(ref.watch(supabaseClientProvider));
