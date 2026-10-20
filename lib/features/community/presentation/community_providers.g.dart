// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_providers.dart';

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

String _$leaderboardHash() => r'62d23d575472f361c918dd7a8104bcee3e2b7fb8';

/// Realtime global feed (newest first).

@ProviderFor(communityFeed)
final communityFeedProvider = CommunityFeedProvider._();

/// Realtime global feed (newest first).

final class CommunityFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedEvent>>,
          List<FeedEvent>,
          Stream<List<FeedEvent>>
        >
    with $FutureModifier<List<FeedEvent>>, $StreamProvider<List<FeedEvent>> {
  /// Realtime global feed (newest first).
  CommunityFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communityFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communityFeedHash();

  @$internal
  @override
  $StreamProviderElement<List<FeedEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedEvent>> create(Ref ref) {
    return communityFeed(ref);
  }
}

String _$communityFeedHash() => r'331e8cd4b68522df9cef1380d33dc1c1c3198b07';

@ProviderFor(playerProfile)
final playerProfileProvider = PlayerProfileFamily._();

final class PlayerProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerProfile>,
          PlayerProfile,
          FutureOr<PlayerProfile>
        >
    with $FutureModifier<PlayerProfile>, $FutureProvider<PlayerProfile> {
  PlayerProfileProvider._({
    required PlayerProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playerProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playerProfileHash();

  @override
  String toString() {
    return r'playerProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlayerProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlayerProfile> create(Ref ref) {
    final argument = this.argument as String;
    return playerProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playerProfileHash() => r'b3e3b7751d1fa0022bf574137976ffa022c645a3';

final class PlayerProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlayerProfile>, String> {
  PlayerProfileFamily._()
    : super(
        retry: null,
        name: r'playerProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlayerProfileProvider call(String userId) =>
      PlayerProfileProvider._(argument: userId, from: this);

  @override
  String toString() => r'playerProfileProvider';
}
