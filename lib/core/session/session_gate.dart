import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the user stands in the app lifecycle. Drives the router redirects.
enum SessionGate { loading, error, signedOut, needsProfile, needsSquad, ready }

/// Pure gate computation.
///
/// - A manual refresh (`ref.invalidate`) keeps the previous value, so the UI
///   never flashes back to the splash screen.
/// - A reload caused by a dependency change (e.g. another user signs in) is
///   treated as loading: the previous user's value must not be trusted.
SessionGate computeSessionGate({
  required AsyncValue<String?> userId,
  required AsyncValue<Object?> profile,
  required AsyncValue<Object?> squad,
}) {
  final userPending = _pending(userId);
  if (userPending != null) return userPending;
  if (userId.value == null) return SessionGate.signedOut;

  final profilePending = _pending(profile);
  if (profilePending != null) return profilePending;
  if (profile.value == null) return SessionGate.needsProfile;

  final squadPending = _pending(squad);
  if (squadPending != null) return squadPending;
  if (squad.value == null) return SessionGate.needsSquad;

  return SessionGate.ready;
}

/// Null when [value] holds a trustworthy value.
SessionGate? _pending(AsyncValue<Object?> value) {
  if (value.hasValue && !value.isReloading) return null;
  if (value.hasError && !value.isLoading) return SessionGate.error;
  return SessionGate.loading;
}
