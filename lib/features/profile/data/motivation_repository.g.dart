// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motivation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(motivationRepository)
final motivationRepositoryProvider = MotivationRepositoryProvider._();

final class MotivationRepositoryProvider
    extends
        $FunctionalProvider<
          MotivationRepository,
          MotivationRepository,
          MotivationRepository
        >
    with $Provider<MotivationRepository> {
  MotivationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'motivationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$motivationRepositoryHash();

  @$internal
  @override
  $ProviderElement<MotivationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MotivationRepository create(Ref ref) {
    return motivationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MotivationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MotivationRepository>(value),
    );
  }
}

String _$motivationRepositoryHash() =>
    r'632f47ddbe373acaaed1c9fa249c786fd8e693e0';

@ProviderFor(myMotivations)
final myMotivationsProvider = MyMotivationsProvider._();

final class MyMotivationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Motivation>>,
          List<Motivation>,
          FutureOr<List<Motivation>>
        >
    with $FutureModifier<List<Motivation>>, $FutureProvider<List<Motivation>> {
  MyMotivationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myMotivationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myMotivationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Motivation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Motivation>> create(Ref ref) {
    return myMotivations(ref);
  }
}

String _$myMotivationsHash() => r'8d78422c871400bd631268741a25f336d104b83e';
