import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  String? get currentUserId => _auth.currentUser?.id;

  String? get currentEmail => _auth.currentUser?.email;

  /// Emits the signed-in user id (or null) now and on every auth change.
  Stream<String?> watchUserId() async* {
    yield _auth.currentUser?.id;
    yield* _auth.onAuthStateChange.map((state) => state.session?.user.id);
  }

  /// Sends a 6-digit code by email (creates the account if needed).
  Future<void> sendOtp(String email) =>
      _auth.signInWithOtp(email: email.trim().toLowerCase());

  Future<void> verifyOtp({required String email, required String code}) =>
      _auth.verifyOTP(
        email: email.trim().toLowerCase(),
        token: code.trim(),
        type: OtpType.email,
      );

  Future<void> signOut() => _auth.signOut();

  /// Drops the local session only: used after the account was deleted, when
  /// the server no longer knows the session.
  Future<void> signOutLocally() => _auth.signOut(scope: SignOutScope.local);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));
