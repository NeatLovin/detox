// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_banner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Latest published build; errors are swallowed (an update check must never
/// break the home screen).

@ProviderFor(latestRelease)
final latestReleaseProvider = LatestReleaseProvider._();

/// Latest published build; errors are swallowed (an update check must never
/// break the home screen).

final class LatestReleaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppRelease?>,
          AppRelease?,
          FutureOr<AppRelease?>
        >
    with $FutureModifier<AppRelease?>, $FutureProvider<AppRelease?> {
  /// Latest published build; errors are swallowed (an update check must never
  /// break the home screen).
  LatestReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestReleaseHash();

  @$internal
  @override
  $FutureProviderElement<AppRelease?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppRelease?> create(Ref ref) {
    return latestRelease(ref);
  }
}

String _$latestReleaseHash() => r'f92bc1cbe6846cc1b8e47514e0fd7656fc7c2aa1';

/// Version dismissed with "Plus tard" during this session.

@ProviderFor(DismissedUpdate)
final dismissedUpdateProvider = DismissedUpdateProvider._();

/// Version dismissed with "Plus tard" during this session.
final class DismissedUpdateProvider
    extends $NotifierProvider<DismissedUpdate, int?> {
  /// Version dismissed with "Plus tard" during this session.
  DismissedUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedUpdateHash();

  @$internal
  @override
  DismissedUpdate create() => DismissedUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$dismissedUpdateHash() => r'7ad6f17eb959b0885994162b3b1e15fb87b15001';

/// Version dismissed with "Plus tard" during this session.

abstract class _$DismissedUpdate extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
