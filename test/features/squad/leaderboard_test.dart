import 'package:detox/core/utils/time_ago.dart';
import 'package:detox/features/squad/domain/leaderboard.dart';
import 'package:detox/features/squad/domain/squad.dart';
import 'package:flutter_test/flutter_test.dart';

LeaderboardEntry entry(String name, {int weekly = 0, int xp = 0}) =>
    LeaderboardEntry(
      userId: name.toLowerCase(),
      username: name,
      avatarEmoji: '😎',
      level: 1,
      hp: 100,
      xp: xp,
      weeklyXp: weekly,
    );

void main() {
  group('LeaderboardView', () {
    test('sorted by weekly XP, podium = top 3', () {
      final view = LeaderboardView.from([
        entry('Bob', weekly: 50),
        entry('Alice', weekly: 300),
        entry('Dan', weekly: 10),
        entry('Charlie', weekly: 120),
      ]);
      expect(view.podium.map((e) => e.username), ['Alice', 'Charlie', 'Bob']);
      expect(view.others.map((e) => e.username), ['Dan']);
      expect(view.rankOf('dan'), 4);
      expect(view.rankOf('alice'), 1);
      expect(view.rankOf('nobody'), isNull);
    });

    test('ties broken by total XP then name', () {
      final view = LeaderboardView.from([
        entry('Zed', weekly: 100, xp: 500),
        entry('Amy', weekly: 100, xp: 500),
        entry('Max', weekly: 100, xp: 900),
      ]);
      expect(view.podium.map((e) => e.username), ['Max', 'Amy', 'Zed']);
    });

    test('small squads', () {
      expect(LeaderboardView.from([]).podium, isEmpty);
      final solo = LeaderboardView.from([entry('Solo')]);
      expect(solo.podium.length, 1);
      expect(solo.others, isEmpty);
    });
  });

  group('TimeAgo', () {
    final now = DateTime.utc(2026, 6, 1, 12);

    test('buckets', () {
      expect(
        TimeAgo.between(now.subtract(const Duration(seconds: 30)), now),
        const TimeAgo(TimeAgoUnit.now, 0),
      );
      expect(
        TimeAgo.between(now.subtract(const Duration(minutes: 5)), now),
        const TimeAgo(TimeAgoUnit.minutes, 5),
      );
      expect(
        TimeAgo.between(now.subtract(const Duration(hours: 3)), now),
        const TimeAgo(TimeAgoUnit.hours, 3),
      );
      expect(
        TimeAgo.between(now.subtract(const Duration(days: 2)), now),
        const TimeAgo(TimeAgoUnit.days, 2),
      );
    });

    test('future timestamps (clock drift) read as now', () {
      expect(
        TimeAgo.between(now.add(const Duration(minutes: 2)), now).unit,
        TimeAgoUnit.now,
      );
    });
  });
}
