// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craving_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recentCravings)
final recentCravingsProvider = RecentCravingsProvider._();

final class RecentCravingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Craving>>,
          List<Craving>,
          FutureOr<List<Craving>>
        >
    with $FutureModifier<List<Craving>>, $FutureProvider<List<Craving>> {
  RecentCravingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentCravingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentCravingsHash();

  @$internal
  @override
  $FutureProviderElement<List<Craving>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Craving>> create(Ref ref) {
    return recentCravings(ref);
  }
}

String _$recentCravingsHash() => r'a837fd3e0729cadbd587030660a7379c774ea338';
