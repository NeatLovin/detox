// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playerStatsRepository)
final playerStatsRepositoryProvider = PlayerStatsRepositoryProvider._();

final class PlayerStatsRepositoryProvider
    extends
        $FunctionalProvider<
          PlayerStatsRepository,
          PlayerStatsRepository,
          PlayerStatsRepository
        >
    with $Provider<PlayerStatsRepository> {
  PlayerStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerStatsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerStatsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayerStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayerStatsRepository create(Ref ref) {
    return playerStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerStatsRepository>(value),
    );
  }
}

String _$playerStatsRepositoryHash() =>
    r'ae686d0db41bbbf9c2f470cae5f5cea88fdadc85';
