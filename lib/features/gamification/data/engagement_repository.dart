import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/utils/day.dart';
import '../domain/badges.dart';

part 'engagement_repository.g.dart';

/// Morning pledge and badges (both written server side only).
class EngagementRepository {
  EngagementRepository(this._client);

  final SupabaseClient _client;

  Future<bool> hasPledgedOn(DateTime day) async {
    final row = await _client
        .from('pledges')
        .select('day')
        .eq('day', dayKey(day))
        .maybeSingle();
    return row != null;
  }

  /// True when the pledge is new today, false if it was already made.
  Future<bool> pledge() async {
    final created = await _client.rpc<dynamic>('make_pledge');
    return created == true;
  }

  Future<List<UnlockedBadge>> fetchBadges(String userId) async {
    final rows = await _client
        .from('badges')
        .select('key, unlocked_at')
        .eq('user_id', userId)
        .order('unlocked_at');
    return [
      for (final row in rows)
        if (BadgeKey.fromDb(row['key'] as String?) case final key?)
          UnlockedBadge(
            key: key,
            unlockedAt: DateTime.parse(row['unlocked_at'] as String),
          ),
    ];
  }
}

@Riverpod(keepAlive: true)
EngagementRepository engagementRepository(Ref ref) =>
    EngagementRepository(ref.watch(supabaseClientProvider));
