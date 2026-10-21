/// Which leaderboard the community screen shows.
enum LeaderboardScope { week, allTime }

/// Weekly leaderboard period: Monday 00:00 to the next Monday 00:00, in the
/// device's local time (the players live in Switzerland, like the server's
/// Europe/Zurich week). Built with calendar fields so DST changes are safe.
abstract final class LeaderboardWeek {
  static DateTime startOf(DateTime now) =>
      DateTime(now.year, now.month, now.day - (now.weekday - DateTime.monday));

  static DateTime endOf(DateTime now) {
    final start = startOf(now);
    return DateTime(start.year, start.month, start.day + 7);
  }

  static Duration remaining(DateTime now) => endOf(now).difference(now);
}
