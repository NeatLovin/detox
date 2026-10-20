// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Realtime SOS alerts of every public player (newest first).

@ProviderFor(sosAlerts)
final sosAlertsProvider = SosAlertsProvider._();

/// Realtime SOS alerts of every public player (newest first).

final class SosAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SosAlert>>,
          List<SosAlert>,
          Stream<List<SosAlert>>
        >
    with $FutureModifier<List<SosAlert>>, $StreamProvider<List<SosAlert>> {
  /// Realtime SOS alerts of every public player (newest first).
  SosAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sosAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sosAlertsHash();

  @$internal
  @override
  $StreamProviderElement<List<SosAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SosAlert>> create(Ref ref) {
    return sosAlerts(ref);
  }
}

String _$sosAlertsHash() => r'758aaa209ec2fa181a9b119741d0833f4b67b6be';

/// Realtime supports received by one SOS.

@ProviderFor(sosSupports)
final sosSupportsProvider = SosSupportsFamily._();

/// Realtime supports received by one SOS.

final class SosSupportsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SosSupport>>,
          List<SosSupport>,
          Stream<List<SosSupport>>
        >
    with $FutureModifier<List<SosSupport>>, $StreamProvider<List<SosSupport>> {
  /// Realtime supports received by one SOS.
  SosSupportsProvider._({
    required SosSupportsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sosSupportsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sosSupportsHash();

  @override
  String toString() {
    return r'sosSupportsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SosSupport>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SosSupport>> create(Ref ref) {
    final argument = this.argument as String;
    return sosSupports(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SosSupportsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sosSupportsHash() => r'7937cae40a1974aab7f1aba0a279debb82543722';

/// Realtime supports received by one SOS.

final class SosSupportsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SosSupport>>, String> {
  SosSupportsFamily._()
    : super(
        retry: null,
        name: r'sosSupportsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Realtime supports received by one SOS.

  SosSupportsProvider call(String alertId) =>
      SosSupportsProvider._(argument: alertId, from: this);

  @override
  String toString() => r'sosSupportsProvider';
}
