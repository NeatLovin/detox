import 'package:detox/features/addictions/domain/addiction_progress.dart';
import 'package:detox/features/gamification/domain/milestones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 1, 10, 8);

  group('cleanDuration / fullCleanDays', () {
    test('elapsed time since the streak start', () {
      final now = start.add(const Duration(days: 3, hours: 5));
      final clean = AddictionProgress.cleanDuration(start, now);
      expect(clean, const Duration(days: 3, hours: 5));
      expect(AddictionProgress.fullCleanDays(clean), 3);
    });

    test('a streak starting in the future counts as zero', () {
      final clean = AddictionProgress.cleanDuration(
        start,
        start.subtract(const Duration(minutes: 5)),
      );
      expect(clean, Duration.zero);
      expect(AddictionProgress.fullCleanDays(clean), 0);
    });

    test('quit date far in the past', () {
      final quit = DateTime.utc(2024, 1, 1);
      final now = DateTime.utc(2026, 1, 1);
      final clean = AddictionProgress.cleanDuration(quit, now);
      expect(AddictionProgress.fullCleanDays(clean), 731);
    });

    test('a day is exactly 24 h (boundary)', () {
      final almost = start.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      );
      expect(
        AddictionProgress.fullCleanDays(
          AddictionProgress.cleanDuration(start, almost),
        ),
        0,
      );
      expect(
        AddictionProgress.fullCleanDays(
          AddictionProgress.cleanDuration(
            start,
            start.add(const Duration(days: 1)),
          ),
        ),
        1,
      );
    });

    test('spring DST (Europe/Zurich, 29.03.2026): a day is 24 real hours', () {
      // 28.03 12:00 CET → 29.03 12:00 CEST is only 23 h of real time.
      final quit = DateTime.parse('2026-03-28T12:00:00+01:00');
      final sameWallClock = DateTime.parse('2026-03-29T12:00:00+02:00');
      final clean = AddictionProgress.cleanDuration(quit, sameWallClock);
      expect(clean, const Duration(hours: 23));
      expect(AddictionProgress.fullCleanDays(clean), 0);
      final oneHourLater = DateTime.parse('2026-03-29T13:00:00+02:00');
      expect(
        AddictionProgress.fullCleanDays(
          AddictionProgress.cleanDuration(quit, oneHourLater),
        ),
        1,
      );
    });

    test('autumn DST (Europe/Zurich, 25.10.2026): no extra day', () {
      // 24.10 12:00 CEST → 25.10 12:00 CET is 25 h of real time.
      final quit = DateTime.parse('2026-10-24T12:00:00+02:00');
      final sameWallClock = DateTime.parse('2026-10-25T12:00:00+01:00');
      final clean = AddictionProgress.cleanDuration(quit, sameWallClock);
      expect(clean, const Duration(hours: 25));
      expect(AddictionProgress.fullCleanDays(clean), 1);
      expect(
        AddictionProgress.split(clean),
        const DurationParts(days: 1, hours: 1, minutes: 0, seconds: 0),
      );
    });
  });

  group('money and units', () {
    test('prorated over the streak', () {
      const clean = Duration(days: 10);
      expect(
        AddictionProgress.moneySaved(
          clean: clean,
          unitCost: 0.45,
          baselinePerDay: 10,
        ),
        closeTo(45, 1e-9),
      );
      expect(
        AddictionProgress.unitsAvoided(clean: clean, baselinePerDay: 10),
        closeTo(100, 1e-9),
      );
    });

    test('half a day gives half the savings', () {
      expect(
        AddictionProgress.moneySaved(
          clean: const Duration(hours: 12),
          unitCost: 6,
          baselinePerDay: 2,
        ),
        closeTo(6, 1e-9),
      );
    });

    test('free addiction saves nothing but still avoids units', () {
      const clean = Duration(days: 3);
      expect(
        AddictionProgress.moneySaved(
          clean: clean,
          unitCost: 0,
          baselinePerDay: 1,
        ),
        0,
      );
      expect(
        AddictionProgress.unitsAvoided(clean: clean, baselinePerDay: 1),
        3,
      );
    });

    test('roundedUnits floors and never goes negative', () {
      expect(AddictionProgress.roundedUnits(2.99), 2);
      expect(AddictionProgress.roundedUnits(-1), 0);
    });
  });

  group('bestStreak', () {
    test('keeps the stored record when longer', () {
      expect(
        AddictionProgress.bestStreak(
          bestStreakSeconds: 86400 * 10,
          current: const Duration(days: 2),
        ),
        const Duration(days: 10),
      );
    });

    test('the current streak becomes the record when longer', () {
      expect(
        AddictionProgress.bestStreak(
          bestStreakSeconds: 3600,
          current: const Duration(days: 2),
        ),
        const Duration(days: 2),
      );
    });
  });

  group('nextMilestone', () {
    test('first milestone is 1 day', () {
      final next = AddictionProgress.nextMilestone(const Duration(hours: 12))!;
      expect(next.milestone, const Milestone(1, 20));
      expect(next.ratio, closeTo(0.5, 1e-9));
      expect(next.remaining, const Duration(hours: 12));
    });

    test('progress is measured from the previous milestone', () {
      // Between 7 (reached) and 14: day 10.5 → 3.5 / 7 = 0.5
      final next = AddictionProgress.nextMilestone(
        const Duration(days: 10, hours: 12),
      )!;
      expect(next.milestone, const Milestone(14, 150));
      expect(next.ratio, closeTo(0.5, 1e-9));
    });

    test('exactly on a milestone targets the following one', () {
      final next = AddictionProgress.nextMilestone(const Duration(days: 30))!;
      expect(next.milestone.days, 60);
      expect(next.ratio, 0);
    });

    test('after 365 days there is no next milestone', () {
      expect(
        AddictionProgress.nextMilestone(const Duration(days: 365)),
        isNull,
      );
      expect(
        AddictionProgress.nextMilestone(const Duration(days: 999)),
        isNull,
      );
    });
  });

  group('split', () {
    test('days hours minutes seconds', () {
      expect(
        AddictionProgress.split(
          const Duration(days: 2, hours: 3, minutes: 4, seconds: 5),
        ),
        const DurationParts(days: 2, hours: 3, minutes: 4, seconds: 5),
      );
      expect(
        AddictionProgress.split(const Duration(seconds: -5)),
        const DurationParts(days: 0, hours: 0, minutes: 0, seconds: 0),
      );
    });
  });

  group('checkRelapseTime', () {
    final now = DateTime.utc(2026, 5, 1, 12);
    final streak = DateTime.utc(2026, 4, 20);

    test('now is fine', () {
      expect(
        AddictionProgress.checkRelapseTime(
          occurredAt: now,
          streakStartedAt: streak,
          now: now,
        ),
        RelapseTimeCheck.ok,
      );
    });

    test('a relapse in the future is rejected', () {
      expect(
        AddictionProgress.checkRelapseTime(
          occurredAt: now.add(const Duration(hours: 1)),
          streakStartedAt: streak,
          now: now,
        ),
        RelapseTimeCheck.inFuture,
      );
    });

    test('small clock drift is tolerated', () {
      expect(
        AddictionProgress.checkRelapseTime(
          occurredAt: now.add(const Duration(seconds: 30)),
          streakStartedAt: streak,
          now: now,
        ),
        RelapseTimeCheck.ok,
      );
    });

    test('a relapse before the current streak is rejected', () {
      expect(
        AddictionProgress.checkRelapseTime(
          occurredAt: streak.subtract(const Duration(minutes: 1)),
          streakStartedAt: streak,
          now: now,
        ),
        RelapseTimeCheck.beforeStreak,
      );
    });

    test('a relapse in the past during the streak is fine', () {
      expect(
        AddictionProgress.checkRelapseTime(
          occurredAt: DateTime.utc(2026, 4, 25),
          streakStartedAt: streak,
          now: now,
        ),
        RelapseTimeCheck.ok,
      );
    });
  });

  group('isValidQuitDate', () {
    final now = DateTime.utc(2026, 5, 1, 12);

    test('past and present are allowed', () {
      expect(
        AddictionProgress.isValidQuitDate(DateTime.utc(2020), now),
        isTrue,
      );
      expect(AddictionProgress.isValidQuitDate(now, now), isTrue);
    });

    test('future is rejected', () {
      expect(
        AddictionProgress.isValidQuitDate(
          now.add(const Duration(days: 1)),
          now,
        ),
        isFalse,
      );
    });
  });
}
