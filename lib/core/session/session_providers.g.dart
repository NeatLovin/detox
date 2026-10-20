// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signed-in user id, or null when signed out.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Signed-in user id, or null when signed out.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Signed-in user id, or null when signed out.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'49550086b8f9ac76cc4f487ac53b725ad92db3d9';

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'197a2730d1244cd66be16b43d8934be6ae47d00c';

@ProviderFor(currentSquad)
final currentSquadProvider = CurrentSquadProvider._();

final class CurrentSquadProvider
    extends $FunctionalProvider<AsyncValue<Squad?>, Squad?, FutureOr<Squad?>>
    with $FutureModifier<Squad?>, $FutureProvider<Squad?> {
  CurrentSquadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSquadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSquadHash();

  @$internal
  @override
  $FutureProviderElement<Squad?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Squad?> create(Ref ref) {
    return currentSquad(ref);
  }
}

String _$currentSquadHash() => r'd6fcf94baab922cf2305baaf47e190da4e877f9c';

/// Realtime XP / HP / level of the signed-in user.

@ProviderFor(playerStats)
final playerStatsProvider = PlayerStatsProvider._();

/// Realtime XP / HP / level of the signed-in user.

final class PlayerStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerStats>,
          PlayerStats,
          Stream<PlayerStats>
        >
    with $FutureModifier<PlayerStats>, $StreamProvider<PlayerStats> {
  /// Realtime XP / HP / level of the signed-in user.
  PlayerStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerStatsHash();

  @$internal
  @override
  $StreamProviderElement<PlayerStats> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlayerStats> create(Ref ref) {
    return playerStats(ref);
  }
}

String _$playerStatsHash() => r'979d3208f5e9a415980a5bcf0e9885617bdc4bd2';

@ProviderFor(sessionGate)
final sessionGateProvider = SessionGateProvider._();

final class SessionGateProvider
    extends $FunctionalProvider<SessionGate, SessionGate, SessionGate>
    with $Provider<SessionGate> {
  SessionGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionGateHash();

  @$internal
  @override
  $ProviderElement<SessionGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionGate create(Ref ref) {
    return sessionGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionGate>(value),
    );
  }
}

String _$sessionGateHash() => r'99573dd3b0b4a231a53db774e258117d60ef32af';
