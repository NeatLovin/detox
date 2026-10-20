// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(squadRepository)
final squadRepositoryProvider = SquadRepositoryProvider._();

final class SquadRepositoryProvider
    extends
        $FunctionalProvider<SquadRepository, SquadRepository, SquadRepository>
    with $Provider<SquadRepository> {
  SquadRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'squadRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$squadRepositoryHash();

  @$internal
  @override
  $ProviderElement<SquadRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SquadRepository create(Ref ref) {
    return squadRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SquadRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SquadRepository>(value),
    );
  }
}

String _$squadRepositoryHash() => r'a8b507474b32c4534b58039d9cb6b35090e48cf0';
