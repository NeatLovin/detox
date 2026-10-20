import 'package:detox/features/gamification/domain/leveling.dart';
import 'package:detox/features/gamification/domain/milestones.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('xpForLevel', () {
    test('50·L·(L−1)', () {
      expect(xpForLevel(1), 0);
      expect(xpForLevel(2), 100);
      expect(xpForLevel(3), 300);
      expect(xpForLevel(4), 600);
      expect(xpForLevel(5), 1000);
    });

    test('levels below 1 are treated as 1', () {
      expect(xpForLevel(0), 0);
      expect(xpForLevel(-3), 0);
    });
  });

  group('levelForXp', () {
    test('reference values (same as SQL)', () {
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(299), 2);
      expect(levelForXp(300), 3);
      expect(levelForXp(1000), 5);
      expect(levelForXp(10000), 14);
    });

    test('negative XP is level 1', () {
      expect(levelForXp(-50), 1);
    });

    test('inverse of xpForLevel on every boundary up to level 200', () {
      for (var level = 1; level <= 200; level++) {
        final threshold = xpForLevel(level);
        expect(levelForXp(threshold), level, reason: 'xp=$threshold');
        if (threshold > 0) {
          expect(
            levelForXp(threshold - 1),
            level - 1,
            reason: 'xp=${threshold - 1}',
          );
        }
      }
    });
  });

  group('LevelProgress', () {
    test('progress inside the current level', () {
      final progress = LevelProgress.fromXp(450);
      expect(progress.level, 3);
      expect(progress.xpIntoLevel, 150);
      expect(progress.xpForNextLevel, 300);
      expect(progress.ratio, closeTo(0.5, 1e-9));
    });

    test('exactly on a level boundary starts at 0', () {
      final progress = LevelProgress.fromXp(600);
      expect(progress.level, 4);
      expect(progress.xpIntoLevel, 0);
      expect(progress.ratio, 0);
    });

    test('fresh player', () {
      final progress = LevelProgress.fromXp(0);
      expect(progress.level, 1);
      expect(progress.xpForNextLevel, 100);
    });
  });

  group('Milestones', () {
    test('ascending days, one-shot bonuses', () {
      final days = Milestones.all.map((m) => m.days).toList();
      expect(days, [1, 3, 7, 14, 30, 60, 90, 180, 365]);
      expect(Milestones.all.first.bonusXp, 20);
      expect(Milestones.all.last.bonusXp, 2000);
    });

    test('a relapse costs HP only', () {
      expect(Milestones.hpPerRelapse, 25);
      expect(Milestones.hpPerCleanDay, 5);
    });
  });
}
