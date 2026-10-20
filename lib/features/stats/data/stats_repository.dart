import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/stats.dart';

part 'stats_repository.g.dart';

class StatsRepository {
  StatsRepository(this._client);

  final SupabaseClient _client;

  /// Own XP ledger since [since] (RLS: owner only).
  Future<List<XpEntry>> fetchXpSince(DateTime since) async {
    final rows = await _client
        .from('xp_ledger')
        .select('created_at, amount_xp')
        .gt('amount_xp', 0)
        .gte('created_at', since.toUtc().toIso8601String())
        .order('created_at');
    return [for (final row in rows) XpEntry.fromJson(row)];
  }
}

@Riverpod(keepAlive: true)
StatsRepository statsRepository(Ref ref) =>
    StatsRepository(ref.watch(supabaseClientProvider));
