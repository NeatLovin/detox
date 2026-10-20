import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/utils/day.dart';
import '../domain/quest.dart';

part 'quest_repository.g.dart';

class QuestRepository {
  QuestRepository(this._client);

  final SupabaseClient _client;

  /// RLS restricts the result to the signed-in user's quests.
  Future<List<DailyQuest>> fetchMine() async {
    final rows = await _client.from('daily_quests').select().order('created_at');
    return [for (final row in rows) DailyQuest.fromJson(row)];
  }

  Future<void> create(QuestDraft draft) => _client.from('daily_quests').insert({
    'type': draft.type.dbValue,
    'label': draft.label.trim(),
    'unit_label': draft.unitLabel.trim(),
    'target': draft.target,
  });

  Future<void> update(String id, QuestDraft draft) => _client
      .from('daily_quests')
      .update({
        'label': draft.label.trim(),
        'unit_label': draft.unitLabel.trim(),
        'target': draft.target,
      })
      .eq('id', id);

  Future<void> archive(String id) => _client
      .from('daily_quests')
      .update({'archived_at': DateTime.now().toUtc().toIso8601String()})
      .eq('id', id);

  Future<List<QuestLog>> fetchLogsSince(DateTime since) async {
    final rows = await _client
        .from('quest_logs')
        .select('quest_id, day, value, done, xp_awarded')
        .gte('day', dayKey(since));
    return [for (final row in rows) QuestLog.fromJson(row)];
  }

  /// Sets today's progress (XP and bonuses are computed server side).
  Future<QuestLog> log(String questId, double value, {DateTime? day}) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'log_quest',
      params: {
        'p_quest_id': questId,
        'p_value': value,
        if (day != null) 'p_day': dayKey(day),
      },
    );
    return QuestLog.fromJson(row);
  }
}

@Riverpod(keepAlive: true)
QuestRepository questRepository(Ref ref) =>
    QuestRepository(ref.watch(supabaseClientProvider));
