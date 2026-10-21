import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'settings_repository.g.dart';

class SettingsRepository {
  SettingsRepository(this._client);

  final SupabaseClient _client;

  /// TWINT number for donations, null when the owner has not set one.
  Future<String?> fetchTwintPhone() async {
    final row = await _client
        .from('app_config')
        .select('twint_phone')
        .maybeSingle();
    final phone = row?['twint_phone'] as String?;
    return phone == null || phone.trim().isEmpty ? null : phone;
  }

  /// Erases the account and every row that belongs to it (server-side RPC).
  Future<void> deleteMyAccount() => _client.rpc<void>('delete_my_account');
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<String?> twintPhone(Ref ref) =>
    ref.watch(settingsRepositoryProvider).fetchTwintPhone();
