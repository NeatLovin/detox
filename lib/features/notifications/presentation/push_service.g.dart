// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Routes opened from tapped notifications, consumed by the home shell.

@ProviderFor(PendingNotificationRoute)
final pendingNotificationRouteProvider = PendingNotificationRouteProvider._();

/// Routes opened from tapped notifications, consumed by the home shell.
final class PendingNotificationRouteProvider
    extends $NotifierProvider<PendingNotificationRoute, String?> {
  /// Routes opened from tapped notifications, consumed by the home shell.
  PendingNotificationRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingNotificationRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingNotificationRouteHash();

  @$internal
  @override
  PendingNotificationRoute create() => PendingNotificationRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingNotificationRouteHash() =>
    r'da476acd83d3ec3b43d375f3fa547761583159b8';

/// Routes opened from tapped notifications, consumed by the home shell.

abstract class _$PendingNotificationRoute extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Registers this device for the signed-in user and keeps the token fresh.
/// Watched by the home shell: runs once per signed-in session.

@ProviderFor(pushSetup)
final pushSetupProvider = PushSetupProvider._();

/// Registers this device for the signed-in user and keeps the token fresh.
/// Watched by the home shell: runs once per signed-in session.

final class PushSetupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Registers this device for the signed-in user and keeps the token fresh.
  /// Watched by the home shell: runs once per signed-in session.
  PushSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushSetupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return pushSetup(ref);
  }
}

String _$pushSetupHash() => r'1c6853c39b28c1d8cfec7bd8a4db1ba5302fca57';
