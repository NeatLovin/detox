import 'package:detox/features/addictions/domain/addiction.dart';
import 'package:detox/features/cravings/domain/craving.dart';
import 'package:detox/features/health/domain/health_sync.dart';
import 'package:detox/features/quests/domain/quest.dart';
import 'package:detox/features/stats/domain/stats.dart';
import 'package:flutter_test/flutter_test.dart';

DailyQuest quest(String id, QuestType type, {double target = 8, DateTime? createdAt}) =>
    DailyQuest(
      id: id,
      type: type,
      label: id,
      unitLabel: 'u',
      target: target,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );

void main() {
  final today = DateTime(2026, 10, 20, 15);

  group('xpPerDay', () {
    test('sums per day, oldest first, missing days at 0', () {
      final series = Stats.xpPerDay([
        XpEntry(at: DateTime(2026, 10, 20, 9), xp: 10),
        XpEntry(at: DateTime(2026, 10, 20, 11), xp: 5),
        XpEntry(at: DateTime(2026, 10, 18, 9), xp: 30),
        XpEntry(at: DateTime(2026, 9, 1), xp: 999),
      ], today, days: 3);
      expect(series.map((d) => d.value), [30, 0, 15]);
      expect(series.first.day, DateTime(2026, 10, 18));
      expect(series.last.day, DateTime(2026, 10, 20));
    });
  });

  group('questCompletion', () {
    test('share of quests done per day, ignoring days before a quest existed', () {
      final quests = [
        quest('a', QuestType.water),
        quest('b', QuestType.sport, createdAt: DateTime(2026, 10, 20, 8)),
      ];
      final logs = [
        QuestLog(questId: 'a', day: DateTime(2026, 10, 19), value: 8, done: true),
        QuestLog(questId: 'a', day: DateTime(2026, 10, 20), value: 8, done: true),
        QuestLog(questId: 'b', day: DateTime(2026, 10, 20), value: 2, done: false),
      ];
      final series = Stats.questCompletion(quests, logs, today, days: 2);
      expect(series.map((d) => d.value), [1.0, 0.5]);
      expect(Stats.questCompletion(const [], logs, today, days: 1).single.value, 0);
    });
  });

  group('cravingHeatmap', () {
    Craving at(DateTime t) => Craving(
      id: '$t',
      addictionId: 'x',
      occurredAt: t,
      intensity: 3,
      trigger: CravingTrigger.other,
      resisted: true,
      viaSos: false,
      xpAwarded: 0,
    );

    test('counts per weekday and 4-hour slot', () {
      // 2026-10-17 is a Saturday.
      final grid = Stats.cravingHeatmap([
        at(DateTime(2026, 10, 17, 23)),
        at(DateTime(2026, 10, 17, 22)),
        at(DateTime(2026, 10, 19, 1)),
      ]);
      expect(grid[5][5], 2);
      expect(grid[0][0], 1);
      expect(Stats.riskiestSlot(grid), (5, 5));
      expect(Stats.riskiestSlot(Stats.cravingHeatmap(const [])), isNull);
    });
  });

  test('AddictionTotals sums current streaks of active addictions', () {
    Addiction addiction(String id, Duration clean, {DateTime? archivedAt}) => Addiction(
      id: id,
      userId: 'u',
      type: AddictionType.snus,
      label: id,
      unitLabel: 'sachets',
      unitCost: 0.5,
      baselinePerDay: 10,
      quitStartedAt: today.subtract(clean),
      streakStartedAt: today.subtract(clean),
      bestStreakSeconds: const Duration(days: 40).inSeconds,
      archivedAt: archivedAt,
      createdAt: today.subtract(clean),
    );
    final totals = AddictionTotals.of([
      addiction('a', const Duration(days: 3, hours: 5)),
      addiction('b', const Duration(days: 10)),
      addiction('c', const Duration(days: 99), archivedAt: today),
    ], today);
    expect(totals.cleanDays, 13);
    expect(totals.bestStreakDays, 40);
    expect(totals.moneySaved, closeTo((3 + 5 / 24 + 10) * 10 * 0.5, 0.01));
  });

  group('Health Connect sync', () {
    QuestProgress progress(QuestType type, double value) =>
        QuestProgress(quest: quest(type.name, type), value: value, streak: 0);

    test('maps steps, sleep hours and workout minutes', () {
      final syncs = questSyncs([
        progress(QuestType.steps, 0),
        progress(QuestType.sleep, 0),
        progress(QuestType.sport, 0),
        progress(QuestType.water, 0),
      ], const HealthReading(steps: 9120, sleepMinutes: 455, workoutMinutes: 42));
      expect(syncs, const [
        QuestSync('steps', 9120),
        QuestSync('sleep', 7.6),
        QuestSync('sport', 42),
      ]);
    });

    test('never lowers a value entered by hand', () {
      final syncs = questSyncs([
        progress(QuestType.steps, 10000),
        progress(QuestType.sport, 60),
      ], const HealthReading(steps: 9120, workoutMinutes: 42));
      expect(syncs, isEmpty);
    });

    test('missing readings change nothing', () {
      expect(questSyncs([progress(QuestType.steps, 0)], const HealthReading()), isEmpty);
      expect(const HealthReading().isEmpty, isTrue);
    });

    test('last night starts at 18:00 the day before', () {
      expect(sleepWindowStart(DateTime(2026, 10, 1, 9)), DateTime(2026, 9, 30, 18));
    });
  });
}
