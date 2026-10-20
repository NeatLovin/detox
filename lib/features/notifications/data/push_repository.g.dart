// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushRepository)
final pushRepositoryProvider = PushRepositoryProvider._();

final class PushRepositoryProvider
    extends $FunctionalProvider<PushRepository, PushRepository, PushRepository>
    with $Provider<PushRepository> {
  PushRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRepositoryHash();

  @$internal
  @override
  $ProviderElement<PushRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushRepository create(Ref ref) {
    return pushRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushRepository>(value),
    );
  }
}

String _$pushRepositoryHash() => r'5b50f4e66a8141d352619feba0e235a51117301e';
