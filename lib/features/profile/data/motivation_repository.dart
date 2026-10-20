import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'motivation_repository.g.dart';

/// "My reasons to quit", shown on the SOS screen. Owner only (RLS), max 5.
class Motivation {
  const Motivation({required this.id, required this.text});

  factory Motivation.fromJson(Map<String, dynamic> json) =>
      Motivation(id: json['id'] as String, text: json['text'] as String);

  final String id;
  final String text;
}

/// Mirrored in SQL: private.on_motivation_before_insert.
const maxMotivations = 5;

class MotivationRepository {
  MotivationRepository(this._client);

  final SupabaseClient _client;

  Future<List<Motivation>> fetchMine() async {
    final rows = await _client
        .from('motivations')
        .select('id, text')
        .order('created_at');
    return [for (final row in rows) Motivation.fromJson(row)];
  }

  Future<void> add(String text) =>
      _client.from('motivations').insert({'text': text.trim()});

  Future<void> update(String id, String text) => _client
      .from('motivations')
      .update({'text': text.trim()})
      .eq('id', id);

  Future<void> delete(String id) =>
      _client.from('motivations').delete().eq('id', id);
}

@Riverpod(keepAlive: true)
MotivationRepository motivationRepository(Ref ref) =>
    MotivationRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Motivation>> myMotivations(Ref ref) =>
    ref.watch(motivationRepositoryProvider).fetchMine();
