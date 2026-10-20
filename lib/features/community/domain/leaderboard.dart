/// One row of the all-time leaderboard (every player, private ones included).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.level,
    required this.xp,
    this.isPrivate = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: (json['rank'] as num).toInt(),
        userId: json['user_id'] as String,
        username: json['username'] as String,
        avatarEmoji: json['avatar_emoji'] as String? ?? '😎',
        level: (json['level'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        isPrivate: json['is_private'] as bool? ?? false,
      );

  /// Shared by ties (same XP, same rank).
  final int rank;
  final String userId;
  final String username;
  final String avatarEmoji;
  final int level;
  final int xp;

  /// The detailed profile does not open for other players.
  final bool isPrivate;
}

/// Leaderboard split into the podium (top 3) and the rest.
class LeaderboardView {
  const LeaderboardView({required this.podium, required this.others});

  /// Sorts by total XP (then name), like the SQL function.
  factory LeaderboardView.from(List<LeaderboardEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) {
        final total = b.xp.compareTo(a.xp);
        if (total != 0) return total;
        return a.username.toLowerCase().compareTo(b.username.toLowerCase());
      });
    return LeaderboardView(
      podium: sorted.take(3).toList(),
      others: sorted.skip(3).toList(),
    );
  }

  final List<LeaderboardEntry> podium;
  final List<LeaderboardEntry> others;

  List<LeaderboardEntry> get all => [...podium, ...others];

  LeaderboardEntry? entryOf(String? userId) =>
      all.where((e) => e.userId == userId).firstOrNull;

  /// user id → username, e.g. to name who launched an SOS.
  Map<String, String> get usernames => {
    for (final e in all) e.userId: e.username,
  };
}
