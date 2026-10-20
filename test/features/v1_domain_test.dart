import 'package:detox/core/utils/day.dart';
import 'package:detox/features/cravings/domain/craving.dart';
import 'package:detox/features/quests/domain/quest.dart';
import 'package:detox/features/quests/domain/quest_catalog.dart';
import 'package:detox/features/sos/domain/sos.dart';
import 'package:flutter_test/flutter_test.dart';

DailyQuest quest({String id = 'q1', double target = 8, QuestType type = QuestType.water}) =>
    DailyQuest(
      id: id,
      type: type,
      label: 'Eau',
      unitLabel: 'verres',
      target: target,
      createdAt: DateTime(2026, 10, 1),
    );

QuestLog log(DateTime day, double value, {String id = 'q1', double target = 8}) =>
    QuestLog(questId: id, day: day, value: value, done: value >= target);

void main() {
  final today = DateTime(2026, 10, 20, 15, 30);

  group('day helpers', () {
    test('dayKey formats a Postgres date', () {
      expect(dayKey(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
    });

    test('parseDay reads a Postgres date as a local day', () {
      expect(parseDay('2026-10-20'), DateTime(2026, 10, 20));
    });

    test('consecutiveDays counts back from today', () {
      final days = [for (var i = 0; i < 4; i++) DateTime(2026, 10, 20 - i)];
      expect(consecutiveDays(days, today), 4);
    });

    test('a streak still counts while today is not done yet', () {
      final days = [DateTime(2026, 10, 19), DateTime(2026, 10, 18)];
      expect(consecutiveDays(days, today), 2);
    });

    test('a gap breaks the streak', () {
      final days = [DateTime(2026, 10, 20), DateTime(2026, 10, 18)];
      expect(consecutiveDays(days, today), 1);
      expect(consecutiveDays(const [], today), 0);
    });

    test('streaks cross month boundaries', () {
      final days = [DateTime(2026, 11, 1), DateTime(2026, 10, 31), DateTime(2026, 10, 30)];
      expect(consecutiveDays(days, DateTime(2026, 11, 1, 9)), 3);
    });
  });

  group('QuestProgress', () {
    test('uses today\'s log and computes the streak from done days', () {
      final logs = [
        log(DateTime(2026, 10, 20), 5),
        log(DateTime(2026, 10, 19), 8),
        log(DateTime(2026, 10, 18), 9),
        log(DateTime(2026, 10, 18), 9, id: 'other'),
      ];
      final p = QuestProgress.of(quest(), logs, today);
      expect(p.value, 5);
      expect(p.done, isFalse);
      expect(p.ratio, closeTo(0.625, 1e-9));
      expect(p.streak, 2);
    });

    test('ratio is capped at 1 and done at target', () {
      final p = QuestProgress.of(quest(), [log(DateTime(2026, 10, 20), 12)], today);
      expect(p.ratio, 1);
      expect(p.done, isTrue);
      expect(p.streak, 1);
    });

    test('QuestDay summary', () {
      final day = QuestDay([
        QuestProgress(quest: quest(), value: 8, streak: 1),
        QuestProgress(quest: quest(id: 'q2'), value: 1, streak: 0),
      ]);
      expect(day.doneCount, 1);
      expect(day.total, 2);
      expect(day.allDone, isFalse);
      expect(const QuestDay([]).allDone, isFalse);
    });
  });

  group('QuestCatalog', () {
    test('every quest type has a preset', () {
      for (final type in QuestType.values) {
        expect(QuestCatalog.of(type).type, type);
      }
    });

    test('a custom quest with target 1 is a toggle', () {
      expect(QuestCatalog.inputFor(quest(type: QuestType.custom, target: 1)), QuestInput.toggle);
      expect(QuestCatalog.inputFor(quest(type: QuestType.custom, target: 3)), QuestInput.stepper);
      expect(QuestCatalog.inputFor(quest(type: QuestType.sleep, target: 7.5)), QuestInput.number);
    });

    test('unknown db values fall back safely', () {
      expect(QuestType.fromDb('nope'), QuestType.custom);
      expect(CravingTrigger.fromDb(null), CravingTrigger.other);
    });
  });

  group('Breathing', () {
    test('phases follow 4 s in, 4 s hold, 6 s out', () {
      expect(Breathing.at(const Duration(seconds: 1)).$1, BreathPhase.inhale);
      expect(Breathing.at(const Duration(seconds: 5)).$1, BreathPhase.hold);
      expect(Breathing.at(const Duration(seconds: 9)).$1, BreathPhase.exhale);
      expect(Breathing.at(const Duration(seconds: 14)).$1, BreathPhase.inhale);
    });

    test('circle grows, holds, then shrinks', () {
      expect(Breathing.scale(Duration.zero), closeTo(0.55, 1e-9));
      expect(Breathing.scale(const Duration(seconds: 5)), 1.0);
      expect(Breathing.scale(const Duration(milliseconds: 13999)), lessThan(0.6));
    });

    test('countdown format never goes negative', () {
      expect(formatCountdown(const Duration(minutes: 5)), '5:00');
      expect(formatCountdown(const Duration(seconds: 65)), '1:05');
      expect(formatCountdown(const Duration(seconds: -3)), '0:00');
    });
  });

  group('SosAlert', () {
    test('is active while open and under 2 hours old', () {
      final alert = SosAlert(
        id: 'a',
        userId: 'u',
        addictionLabel: 'Snus',
        createdAt: today.subtract(const Duration(minutes: 30)),
      );
      expect(alert.isActive(today), isTrue);
      expect(alert.isActive(today.add(const Duration(hours: 2))), isFalse);
    });
  });

  group('CravingStats', () {
    Craving craving(CravingTrigger trigger, {bool resisted = true}) => Craving(
      id: '${trigger.name}$resisted',
      addictionId: 'a',
      occurredAt: today,
      intensity: 3,
      trigger: trigger,
      resisted: resisted,
      viaSos: false,
      xpAwarded: 0,
    );

    test('resisted share and top trigger (ignoring "other")', () {
      final stats = CravingStats.of([
        craving(CravingTrigger.stress),
        craving(CravingTrigger.stress, resisted: false),
        craving(CravingTrigger.other),
        craving(CravingTrigger.other),
        craving(CravingTrigger.party),
      ]);
      expect(stats.total, 5);
      expect(stats.resisted, 4);
      expect(stats.resistedPercent, 80);
      expect(stats.topTrigger, CravingTrigger.stress);
    });

    test('empty journal', () {
      final stats = CravingStats.of(const []);
      expect(stats.resistedPercent, 0);
      expect(stats.topTrigger, isNull);
    });
  });
}
