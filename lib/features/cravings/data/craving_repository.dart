import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/craving.dart';

part 'craving_repository.g.dart';

class CravingRepository {
  CravingRepository(this._client);

  final SupabaseClient _client;

  /// RLS restricts the result to the signed-in user's cravings.
  Future<List<Craving>> fetchRecent({int limit = 50}) async {
    final rows = await _client
        .from('cravings')
        .select()
        .order('occurred_at', ascending: false)
        .limit(limit);
    return [for (final row in rows) Craving.fromJson(row)];
  }

  /// Logs a craving and returns the XP it earned (0 when capped or not resisted).
  /// The XP is written by an AFTER trigger, so it is read back after the insert.
  Future<int> log(CravingInput input) async {
    final inserted = await _client
        .from('cravings')
        .insert({
          'addiction_id': input.addictionId,
          'intensity': input.intensity,
          'trigger': input.trigger.dbValue,
          'resisted': input.resisted,
          if (input.note != null && input.note!.trim().isNotEmpty)
            'note': input.note!.trim(),
        })
        .select('id')
        .single();
    final row = await _client
        .from('cravings')
        .select('xp_awarded')
        .eq('id', inserted['id'] as String)
        .single();
    return (row['xp_awarded'] as num?)?.toInt() ?? 0;
  }

  Future<void> delete(String id) =>
      _client.from('cravings').delete().eq('id', id);
}

@Riverpod(keepAlive: true)
CravingRepository cravingRepository(Ref ref) =>
    CravingRepository(ref.watch(supabaseClientProvider));
