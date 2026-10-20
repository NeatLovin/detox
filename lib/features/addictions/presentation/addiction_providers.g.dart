// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addiction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All addictions of the signed-in user, archived ones included.

@ProviderFor(myAddictions)
final myAddictionsProvider = MyAddictionsProvider._();

/// All addictions of the signed-in user, archived ones included.

final class MyAddictionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Addiction>>,
          List<Addiction>,
          FutureOr<List<Addiction>>
        >
    with $FutureModifier<List<Addiction>>, $FutureProvider<List<Addiction>> {
  /// All addictions of the signed-in user, archived ones included.
  MyAddictionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAddictionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAddictionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Addiction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Addiction>> create(Ref ref) {
    return myAddictions(ref);
  }
}

String _$myAddictionsHash() => r'1ddde89b2d673024a0560bef0c09258003fcaf0e';

@ProviderFor(activeAddictions)
final activeAddictionsProvider = ActiveAddictionsProvider._();

final class ActiveAddictionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Addiction>>,
          List<Addiction>,
          FutureOr<List<Addiction>>
        >
    with $FutureModifier<List<Addiction>>, $FutureProvider<List<Addiction>> {
  ActiveAddictionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeAddictionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeAddictionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Addiction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Addiction>> create(Ref ref) {
    return activeAddictions(ref);
  }
}

String _$activeAddictionsHash() => r'2243073733a68cce7de5180026914466ee66db42';
