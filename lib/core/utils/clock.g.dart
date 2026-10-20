// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Local one-second ticker driving the live timers. No network involved.

@ProviderFor(nowTicker)
final nowTickerProvider = NowTickerProvider._();

/// Local one-second ticker driving the live timers. No network involved.

final class NowTickerProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// Local one-second ticker driving the live timers. No network involved.
  NowTickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowTickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowTickerHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return nowTicker(ref);
  }
}

String _$nowTickerHash() => r'13ec132505093ef6cc5bddf21f0b284815721642';
