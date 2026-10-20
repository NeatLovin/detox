import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../cravings/domain/craving.dart';
import '../domain/sos.dart';

part 'sos_repository.g.dart';

class SosRepository {
  SosRepository(this._client);

  final SupabaseClient _client;

  /// Opens an SOS (or reuses the open one) and alerts the squad. Returns its id.
  Future<String> start(String addictionId) async {
    final id = await _client.rpc<dynamic>(
      'start_sos',
      params: {'p_addiction_id': addictionId},
    );
    return id as String;
  }

  /// Closes the SOS; the outcome is logged server side as a craving.
  Future<void> resolve({
    required String alertId,
    required bool resisted,
    required int intensity,
    required CravingTrigger trigger,
  }) => _client.rpc<void>(
    'resolve_sos',
    params: {
      'p_alert_id': alertId,
      'p_resisted': resisted,
      'p_intensity': intensity,
      'p_trigger': trigger.dbValue,
    },
  );

  Future<void> support({required String alertId, required String emoji}) =>
      _client.rpc<void>(
        'support_sos',
        params: {'p_alert_id': alertId, 'p_emoji': emoji},
      );

  /// Realtime SOS alerts of the squad, newest first.
  Stream<List<SosAlert>> watchSquadAlerts(String squadId) => _client
      .from('sos_alerts')
      .stream(primaryKey: ['id'])
      .eq('squad_id', squadId)
      .order('created_at')
      .limit(20)
      .map((rows) => [for (final row in rows) SosAlert.fromJson(row)]);

  /// Realtime supports received by one alert.
  Stream<List<SosSupport>> watchSupports(String alertId) => _client
      .from('sos_supports')
      .stream(primaryKey: ['alert_id', 'user_id'])
      .eq('alert_id', alertId)
      .map((rows) => [for (final row in rows) SosSupport.fromJson(row)]);
}

@Riverpod(keepAlive: true)
SosRepository sosRepository(Ref ref) =>
    SosRepository(ref.watch(supabaseClientProvider));
