import 'package:flutter/foundation.dart';

import 'feed_event.dart';

/// Same list and order as the SQL check of public.feed_reactions
/// (test/sql_parity_test.dart compares them).
const feedReactionEmojis = <String>['👏', '🔥', '💪', '❤️', '😂'];

/// A relapse or an SOS only gets support, never a laugh (same rule in SQL).
const supportReactionEmojis = <String>['💪', '❤️'];

List<String> allowedReactions(FeedEventType type) => switch (type) {
  FeedEventType.relapse || FeedEventType.sos => supportReactionEmojis,
  _ => feedReactionEmojis,
};

class FeedReaction {
  const FeedReaction({
    required this.eventId,
    required this.userId,
    required this.emoji,
  });

  factory FeedReaction.fromJson(Map<String, dynamic> json) => FeedReaction(
    eventId: json['event_id'] as String,
    userId: json['user_id'] as String,
    emoji: json['emoji'] as String,
  );

  final String eventId;
  final String userId;
  final String emoji;
}

/// Reactions of one event: count per emoji and the player's own one.
@immutable
class ReactionSummary {
  const ReactionSummary({this.counts = const {}, this.mine});

  static const empty = ReactionSummary();

  /// Emoji → count, only emojis with at least one reaction.
  final Map<String, int> counts;
  final String? mine;

  bool get isEmpty => counts.isEmpty;

  /// Emojis with a count, in the catalog order.
  List<MapEntry<String, int>> get ordered => [
    for (final emoji in feedReactionEmojis)
      if ((counts[emoji] ?? 0) > 0) MapEntry(emoji, counts[emoji]!),
  ];

  /// What the summary becomes when the player taps [emoji] (same rule as the
  /// server: the same emoji removes the reaction, another one replaces it).
  ReactionSummary toggle(String emoji) {
    final next = Map<String, int>.of(counts);
    void add(String e, int delta) {
      final value = (next[e] ?? 0) + delta;
      if (value > 0) {
        next[e] = value;
      } else {
        next.remove(e);
      }
    }

    if (mine != null) add(mine!, -1);
    if (mine == emoji) return ReactionSummary(counts: next);
    add(emoji, 1);
    return ReactionSummary(counts: next, mine: emoji);
  }

  @override
  bool operator ==(Object other) =>
      other is ReactionSummary &&
      other.mine == mine &&
      mapEquals(other.counts, counts);

  @override
  int get hashCode => Object.hash(
    mine,
    Object.hashAllUnordered(
      counts.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}

/// Groups reactions by event.
Map<String, ReactionSummary> summarizeReactions(
  Iterable<FeedReaction> reactions,
  String? me,
) {
  final counts = <String, Map<String, int>>{};
  final mine = <String, String>{};
  for (final r in reactions) {
    final perEvent = counts.putIfAbsent(r.eventId, () => {});
    perEvent[r.emoji] = (perEvent[r.emoji] ?? 0) + 1;
    if (r.userId == me) mine[r.eventId] = r.emoji;
  }
  return {
    for (final MapEntry(key: eventId, value: c) in counts.entries)
      eventId: ReactionSummary(counts: c, mine: mine[eventId]),
  };
}
