// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craving_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cravingRepository)
final cravingRepositoryProvider = CravingRepositoryProvider._();

final class CravingRepositoryProvider
    extends
        $FunctionalProvider<
          CravingRepository,
          CravingRepository,
          CravingRepository
        >
    with $Provider<CravingRepository> {
  CravingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cravingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cravingRepositoryHash();

  @$internal
  @override
  $ProviderElement<CravingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CravingRepository create(Ref ref) {
    return cravingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CravingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CravingRepository>(value),
    );
  }
}

String _$cravingRepositoryHash() => r'572d6b89d2c2acb56c9fe51e33bb4be7a77cdd35';
