// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sosRepository)
final sosRepositoryProvider = SosRepositoryProvider._();

final class SosRepositoryProvider
    extends $FunctionalProvider<SosRepository, SosRepository, SosRepository>
    with $Provider<SosRepository> {
  SosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sosRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sosRepositoryHash();

  @$internal
  @override
  $ProviderElement<SosRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SosRepository create(Ref ref) {
    return sosRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SosRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SosRepository>(value),
    );
  }
}

String _$sosRepositoryHash() => r'5e417bc9f25780b0d24f50b8bcaadc080912242f';
