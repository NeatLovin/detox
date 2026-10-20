import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/app_release.dart';

part 'update_repository.g.dart';

class UpdateRepository {
  UpdateRepository(this._client);

  final SupabaseClient _client;

  Future<AppRelease?> fetchLatest() async {
    final row = await _client
        .from('app_releases')
        .select()
        .order('version_code', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : AppRelease.fromJson(row);
  }
}

@Riverpod(keepAlive: true)
UpdateRepository updateRepository(Ref ref) =>
    UpdateRepository(ref.watch(supabaseClientProvider));
