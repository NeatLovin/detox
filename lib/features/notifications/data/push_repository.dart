import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'push_repository.g.dart';

/// Device tokens are written through RPCs only (the table is read-only).
class PushRepository {
  PushRepository(this._client);

  final SupabaseClient _client;

  Future<void> register(String token) => _client.rpc<void>(
    'register_push_token',
    params: {'p_token': token, 'p_platform': 'android'},
  );

  Future<void> unregister(String token) =>
      _client.rpc<void>('unregister_push_token', params: {'p_token': token});
}

@Riverpod(keepAlive: true)
PushRepository pushRepository(Ref ref) =>
    PushRepository(ref.watch(supabaseClientProvider));
