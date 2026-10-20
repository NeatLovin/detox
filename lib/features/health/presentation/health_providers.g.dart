// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthState)
final healthStateProvider = HealthStateProvider._();

final class HealthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthState>,
          HealthState,
          FutureOr<HealthState>
        >
    with $FutureModifier<HealthState>, $FutureProvider<HealthState> {
  HealthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthStateHash();

  @$internal
  @override
  $FutureProviderElement<HealthState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthState> create(Ref ref) {
    return healthState(ref);
  }
}

String _$healthStateHash() => r'431d10440b311b1c1f1381d1bc221a5337f96644';

/// Sync entry point for widgets (Riverpod function provider, re-run on demand
/// with `ref.invalidate(healthSyncProvider)`).

@ProviderFor(healthSync)
final healthSyncProvider = HealthSyncProvider._();

/// Sync entry point for widgets (Riverpod function provider, re-run on demand
/// with `ref.invalidate(healthSyncProvider)`).

final class HealthSyncProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Sync entry point for widgets (Riverpod function provider, re-run on demand
  /// with `ref.invalidate(healthSyncProvider)`).
  HealthSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthSyncHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return healthSync(ref);
  }
}

String _$healthSyncHash() => r'19e8cea981c643769bedd0d027aac4e02ec7cca8';
