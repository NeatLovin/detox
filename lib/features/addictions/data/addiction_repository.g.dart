// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addiction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(addictionRepository)
final addictionRepositoryProvider = AddictionRepositoryProvider._();

final class AddictionRepositoryProvider
    extends
        $FunctionalProvider<
          AddictionRepository,
          AddictionRepository,
          AddictionRepository
        >
    with $Provider<AddictionRepository> {
  AddictionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addictionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addictionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AddictionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddictionRepository create(Ref ref) {
    return addictionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddictionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddictionRepository>(value),
    );
  }
}

String _$addictionRepositoryHash() =>
    r'80debc4ca6233ad291dcc73606824262b98aa5f4';
