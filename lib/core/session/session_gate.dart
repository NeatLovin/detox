import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the user stands in the app lifecycle. Drives the router redirects.
enum SessionGate { loading, error, signedOut, needsProfile, needsSquad, ready }

/// Pure gate computation. Keeps showing the previous value while a provider
/// refreshes, so the UI never flashes back to the splash screen.
SessionGate computeSessionGate({
  required AsyncValue<String?> userId,
  required AsyncValue<Object?> profile,
  required AsyncValue<Object?> squad,
}) {
  if (!userId.hasValue) {
    return userId.hasError ? SessionGate.error : SessionGate.loading;
  }
  if (userId.value == null) return SessionGate.signedOut;

  if (!profile.hasValue) {
    return profile.hasError ? SessionGate.error : SessionGate.loading;
  }
  if (profile.value == null) return SessionGate.needsProfile;

  if (!squad.hasValue) {
    return squad.hasError ? SessionGate.error : SessionGate.loading;
  }
  if (squad.value == null) return SessionGate.needsSquad;

  return SessionGate.ready;
}
