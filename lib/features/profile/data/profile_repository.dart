import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/profile.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final result = await _client.rpc<bool>(
      'is_username_available',
      params: {'name': username.trim()},
    );
    return result;
  }

  Future<Profile> createProfile({
    required String userId,
    required String username,
    required String avatarEmoji,
    bool isPrivate = false,
  }) async {
    final row = await _client
        .from('profiles')
        .insert({
          'id': userId,
          'username': username.trim(),
          'avatar_emoji': avatarEmoji,
          'is_private': isPrivate,
        })
        .select()
        .single();
    return Profile.fromJson(row);
  }

  Future<Profile> updateProfile({
    required String userId,
    required String username,
    required String avatarEmoji,
    required bool isPrivate,
    required bool notifySos,
    required bool notifyReminders,
  }) async {
    final row = await _client
        .from('profiles')
        .update({
          'username': username.trim(),
          'avatar_emoji': avatarEmoji,
          'is_private': isPrivate,
          'notify_sos': notifySos,
          'notify_reminders': notifyReminders,
        })
        .eq('id', userId)
        .select()
        .single();
    return Profile.fromJson(row);
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(supabaseClientProvider));
