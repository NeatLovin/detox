import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/addiction.dart';

part 'addiction_repository.g.dart';

class AddictionRepository {
  AddictionRepository(this._client);

  final SupabaseClient _client;

  /// RLS restricts the result to the signed-in user's addictions.
  Future<List<Addiction>> fetchMine() async {
    final rows = await _client.from('addictions').select().order('created_at');
    return [for (final row in rows) Addiction.fromJson(row)];
  }

  /// Streak columns are server-controlled: only the draft fields are sent.
  Future<void> createAll(List<AddictionDraft> drafts) async {
    if (drafts.isEmpty) return;
    await _client.from('addictions').insert([
      for (final draft in drafts) _insertPayload(draft),
    ]);
  }

  Future<void> create(AddictionDraft draft) => createAll([draft]);

  Future<void> update(String id, AddictionDraft draft) => _client
      .from('addictions')
      .update({
        'label': draft.label.trim(),
        'unit_label': draft.unitLabel.trim(),
        'unit_cost': draft.unitCost,
        'baseline_per_day': draft.baselinePerDay,
        'is_private': draft.isPrivate,
      })
      .eq('id', id);

  /// Archiving goes through an RPC: archived_at is not client-writable and an
  /// archived addiction is frozen server side.
  Future<void> archive(String id) =>
      _client.rpc<void>('archive_addiction', params: {'p_id': id});

  /// The SQL trigger resets the streak, costs 25 HP and posts to the feed if shared.
  Future<void> declareRelapse(RelapseInput input) =>
      _client.from('relapses').insert({
        'addiction_id': input.addictionId,
        'occurred_at': input.occurredAt.toUtc().toIso8601String(),
        if (input.note != null && input.note!.trim().isNotEmpty)
          'note': input.note!.trim(),
        'shared': input.shared,
      });

  Map<String, dynamic> _insertPayload(AddictionDraft draft) => {
    'type': draft.type.dbValue,
    'label': draft.label.trim(),
    'unit_label': draft.unitLabel.trim(),
    'unit_cost': draft.unitCost,
    'baseline_per_day': draft.baselinePerDay,
    'is_private': draft.isPrivate,
    'quit_started_at': draft.quitStartedAt.toUtc().toIso8601String(),
  };
}

@Riverpod(keepAlive: true)
AddictionRepository addictionRepository(Ref ref) =>
    AddictionRepository(ref.watch(supabaseClientProvider));
