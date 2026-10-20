// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squad_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardProvider._();

final class LeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<LeaderboardView>,
          LeaderboardView,
          FutureOr<LeaderboardView>
        >
    with $FutureModifier<LeaderboardView>, $FutureProvider<LeaderboardView> {
  LeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardHash();

  @$internal
  @override
  $FutureProviderElement<LeaderboardView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LeaderboardView> create(Ref ref) {
    return leaderboard(ref);
  }
}

String _$leaderboardHash() => r'426afdd389aeaaa069d7ff9a2494730afe864dff';

@ProviderFor(squadMembers)
final squadMembersProvider = SquadMembersProvider._();

final class SquadMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SquadMember>>,
          List<SquadMember>,
          FutureOr<List<SquadMember>>
        >
    with
        $FutureModifier<List<SquadMember>>,
        $FutureProvider<List<SquadMember>> {
  SquadMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'squadMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$squadMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<SquadMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SquadMember>> create(Ref ref) {
    return squadMembers(ref);
  }
}

String _$squadMembersHash() => r'a716ff31c6316ef36a5e4b9155b7b5b7b1e0de21';

/// Realtime feed (newest first).

@ProviderFor(squadFeed)
final squadFeedProvider = SquadFeedProvider._();

/// Realtime feed (newest first).

final class SquadFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedEvent>>,
          List<FeedEvent>,
          Stream<List<FeedEvent>>
        >
    with $FutureModifier<List<FeedEvent>>, $StreamProvider<List<FeedEvent>> {
  /// Realtime feed (newest first).
  SquadFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'squadFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$squadFeedHash();

  @$internal
  @override
  $StreamProviderElement<List<FeedEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedEvent>> create(Ref ref) {
    return squadFeed(ref);
  }
}

String _$squadFeedHash() => r'dd89e794333769a5df93a5b001895fc13ea9e649';
