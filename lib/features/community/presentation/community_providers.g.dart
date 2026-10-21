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

@ProviderFor(weekLeaderboard)
final weekLeaderboardProvider = WeekLeaderboardProvider._();

final class WeekLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<LeaderboardView>,
          LeaderboardView,
          FutureOr<LeaderboardView>
        >
    with $FutureModifier<LeaderboardView>, $FutureProvider<LeaderboardView> {
  WeekLeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekLeaderboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekLeaderboardHash();

  @$internal
  @override
  $FutureProviderElement<LeaderboardView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LeaderboardView> create(Ref ref) {
    return weekLeaderboard(ref);
  }
}

String _$weekLeaderboardHash() => r'e8e161337e471ece4e34aa66fd1509be8111af89';

/// Leaderboard tab picked on the community screen (the week by default).

@ProviderFor(SelectedLeaderboard)
final selectedLeaderboardProvider = SelectedLeaderboardProvider._();

/// Leaderboard tab picked on the community screen (the week by default).
final class SelectedLeaderboardProvider
    extends $NotifierProvider<SelectedLeaderboard, LeaderboardScope> {
  /// Leaderboard tab picked on the community screen (the week by default).
  SelectedLeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedLeaderboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedLeaderboardHash();

  @$internal
  @override
  SelectedLeaderboard create() => SelectedLeaderboard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaderboardScope value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaderboardScope>(value),
    );
  }
}

String _$selectedLeaderboardHash() =>
    r'17de43434b884199ba522089556873ea7443f20d';

/// Leaderboard tab picked on the community screen (the week by default).

abstract class _$SelectedLeaderboard extends $Notifier<LeaderboardScope> {
  LeaderboardScope build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LeaderboardScope, LeaderboardScope>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LeaderboardScope, LeaderboardScope>,
              LeaderboardScope,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Realtime reactions, grouped by feed event.

@ProviderFor(feedReactions)
final feedReactionsProvider = FeedReactionsProvider._();

/// Realtime reactions, grouped by feed event.

final class FeedReactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, ReactionSummary>>,
          Map<String, ReactionSummary>,
          Stream<Map<String, ReactionSummary>>
        >
    with
        $FutureModifier<Map<String, ReactionSummary>>,
        $StreamProvider<Map<String, ReactionSummary>> {
  /// Realtime reactions, grouped by feed event.
  FeedReactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedReactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedReactionsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, ReactionSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, ReactionSummary>> create(Ref ref) {
    return feedReactions(ref);
  }
}

String _$feedReactionsHash() => r'd4893b43e1073855c609c1eb8108a81749374fe3';
