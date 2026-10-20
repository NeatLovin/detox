import 'package:detox/core/utils/time_ago.dart';
import 'package:detox/features/community/domain/leaderboard.dart';
import 'package:detox/features/community/domain/player_profile.dart';
import 'package:detox/features/gamification/domain/badges.dart';
import 'package:flutter_test/flutter_test.dart';

LeaderboardEntry entry(String name, {int xp = 0, int rank = 1, bool isPrivate = false}) =>
    LeaderboardEntry(
      rank: rank,
      userId: name.toLowerCase(),
      username: name,
      avatarEmoji: '😎',
      level: 1,
      xp: xp,
      isPrivate: isPrivate,
    );

void main() {
  group('LeaderboardView', () {
    test('sorted by total XP, podium = top 3', () {
      final view = LeaderboardView.from([
        entry('Bob', xp: 50),
        entry('Alice', xp: 300),
        entry('Dan', xp: 10),
        entry('Charlie', xp: 120, isPrivate: true),
      ]);
      expect(view.podium.map((e) => e.username), ['Alice', 'Charlie', 'Bob']);
      expect(view.others.map((e) => e.username), ['Dan']);
      expect(view.entryOf('charlie')?.isPrivate, isTrue);
      expect(view.entryOf('nobody'), isNull);
      expect(view.usernames['dan'], 'Dan');
    });

    test('ties broken by name', () {
      final view = LeaderboardView.from([
        entry('Zed', xp: 500),
        entry('Amy', xp: 500),
        entry('Max', xp: 900),
      ]);
      expect(view.podium.map((e) => e.username), ['Max', 'Amy', 'Zed']);
    });

    test('empty and solo', () {
      expect(LeaderboardView.from([]).all, isEmpty);
      final solo = LeaderboardView.from([entry('Solo')]);
      expect(solo.podium.length, 1);
      expect(solo.others, isEmpty);
    });

    test('parses the leaderboard RPC row', () {
      final e = LeaderboardEntry.fromJson({
        'rank': 2,
        'user_id': 'u1',
        'username': 'Bob',
        'avatar_emoji': '🐻',
        'level': 4,
        'xp': 940,
        'is_private': true,
      });
      expect(e.rank, 2);
      expect(e.xp, 940);
      expect(e.isPrivate, isTrue);
    });
  });

  test('PlayerProfile parses the player_profile RPC', () {
    final p = PlayerProfile.fromJson({
      'user_id': 'u1',
      'username': 'Bob',
      'avatar_emoji': '🐻',
      'is_private': false,
      'joined_at': '2026-10-01T10:00:00Z',
      'level': 4,
      'xp': 940,
      'hp': 75,
      'rank': 2,
      'badges': [
        {'key': 'streak_7', 'unlocked_at': '2026-10-08T10:00:00Z'},
        {'key': 'removed_badge', 'unlocked_at': '2026-10-08T10:00:00Z'},
      ],
      'addictions': [
        {
          'id': 'a1',
          'user_id': 'u1',
          'type': 'snus',
          'label': 'Snus',
          'unit_label': 'sachets',
          'unit_cost': 0.45,
          'baseline_per_day': 10,
          'quit_started_at': '2026-10-01T10:00:00Z',
          'streak_started_at': '2026-10-05T10:00:00Z',
          'best_streak_seconds': 3600,
          'created_at': '2026-10-01T10:00:00Z',
        },
      ],
    });
    expect(p.rank, 2);
    expect(p.hp, 75);
    expect(p.badges.map((b) => b.key), [BadgeKey.streak7]);
    expect(p.addictions.single.label, 'Snus');
    expect(p.addictions.single.isPrivate, isFalse);
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
