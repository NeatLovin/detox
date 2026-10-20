import 'squad.dart';

/// Leaderboard split into the podium (top 3) and the rest.
class LeaderboardView {
  const LeaderboardView({required this.podium, required this.others});

  /// Sorts by weekly XP (then total XP, then name), like the SQL function.
  factory LeaderboardView.from(List<LeaderboardEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) {
        final weekly = b.weeklyXp.compareTo(a.weeklyXp);
        if (weekly != 0) return weekly;
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

  /// 1-based rank of [userId], or null if absent.
  int? rankOf(String userId) {
    final index = all.indexWhere((e) => e.userId == userId);
    return index < 0 ? null : index + 1;
  }
}
