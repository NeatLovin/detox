// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_timeline_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bundled content: loaded once, never from the network.

@ProviderFor(healthTimelines)
final healthTimelinesProvider = HealthTimelinesProvider._();

/// Bundled content: loaded once, never from the network.

final class HealthTimelinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<HealthTimelines>,
          HealthTimelines,
          FutureOr<HealthTimelines>
        >
    with $FutureModifier<HealthTimelines>, $FutureProvider<HealthTimelines> {
  /// Bundled content: loaded once, never from the network.
  HealthTimelinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthTimelinesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthTimelinesHash();

  @$internal
  @override
  $FutureProviderElement<HealthTimelines> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HealthTimelines> create(Ref ref) {
    return healthTimelines(ref);
  }
}

String _$healthTimelinesHash() => r'854508cc6685dade2e9d5572a28c757fe2ddb586';
