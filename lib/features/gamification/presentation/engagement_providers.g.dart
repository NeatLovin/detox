// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pledgedToday)
final pledgedTodayProvider = PledgedTodayProvider._();

final class PledgedTodayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  PledgedTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pledgedTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pledgedTodayHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return pledgedToday(ref);
  }
}

String _$pledgedTodayHash() => r'959a3af28858da66b98acbae815f0563bfc742a3';

@ProviderFor(myBadges)
final myBadgesProvider = MyBadgesProvider._();

final class MyBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UnlockedBadge>>,
          List<UnlockedBadge>,
          FutureOr<List<UnlockedBadge>>
        >
    with
        $FutureModifier<List<UnlockedBadge>>,
        $FutureProvider<List<UnlockedBadge>> {
  MyBadgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBadgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBadgesHash();

  @$internal
  @override
  $FutureProviderElement<List<UnlockedBadge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UnlockedBadge>> create(Ref ref) {
    return myBadges(ref);
  }
}

String _$myBadgesHash() => r'e5814ad045e3f35dd67728d9253e0a6ee67e03b4';
