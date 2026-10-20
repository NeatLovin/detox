// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(engagementRepository)
final engagementRepositoryProvider = EngagementRepositoryProvider._();

final class EngagementRepositoryProvider
    extends
        $FunctionalProvider<
          EngagementRepository,
          EngagementRepository,
          EngagementRepository
        >
    with $Provider<EngagementRepository> {
  EngagementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engagementRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engagementRepositoryHash();

  @$internal
  @override
  $ProviderElement<EngagementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EngagementRepository create(Ref ref) {
    return engagementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngagementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngagementRepository>(value),
    );
  }
}

String _$engagementRepositoryHash() =>
    r'f4da247d40d1641292982ff7f4fe22fe41c9c7b0';
