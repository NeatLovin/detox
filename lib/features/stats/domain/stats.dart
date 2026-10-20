import '../../../core/utils/day.dart';
import '../../addictions/domain/addiction.dart';
import '../../addictions/domain/addiction_progress.dart';
import '../../cravings/domain/craving.dart';
import '../../quests/domain/quest.dart';

/// One ledger row, as needed by the stats (XP only, HP is not charted).
class XpEntry {
  const XpEntry({required this.at, required this.xp});

  factory XpEntry.fromJson(Map<String, dynamic> json) => XpEntry(
    at: DateTime.parse(json['created_at'] as String),
    xp: (json['amount_xp'] as num).toInt(),
  );

  final DateTime at;
  final int xp;
}

/// Value for one calendar day of a chart.
class DayValue {
  const DayValue(this.day, this.value);

  final DateTime day;
  final double value;
}

abstract final class Stats {
  /// XP earned per day over the [days] days ending on [today] (oldest first,
  /// days without XP included as 0).
  static List<DayValue> xpPerDay(Iterable<XpEntry> entries, DateTime today, {int days = 30}) {
    final totals = <String, int>{};
    for (final e in entries) {
      final key = dayKey(e.at);
      totals[key] = (totals[key] ?? 0) + e.xp;
    }
    final end = dayOf(today);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final day = DateTime(end.year, end.month, end.day - i);
          return DayValue(day, (totals[dayKey(day)] ?? 0).toDouble());
        }(),
    ];
  }

  /// Share (0..1) of active quests done each day over the [days] days ending
  /// on [today]. Days before a quest existed do not count against it.
  static List<DayValue> questCompletion(
    List<DailyQuest> quests,
    Iterable<QuestLog> logs,
    DateTime today, {
    int days = 14,
  }) {
    final done = {
      for (final l in logs)
        if (l.done) '${l.questId}|${dayKey(l.day)}',
    };
    final end = dayOf(today);
    return [
      for (var i = days - 1; i >= 0; i--)
        () {
          final day = DateTime(end.year, end.month, end.day - i);
          final existing = quests.where((q) => !dayOf(q.createdAt).isAfter(day)).toList();
          if (existing.isEmpty) return DayValue(day, 0);
          final count = existing.where((q) => done.contains('${q.id}|${dayKey(day)}')).length;
          return DayValue(day, count / existing.length);
        }(),
    ];
  }

  /// Number of cravings per weekday (0 = Monday) and 4-hour slot (0 = 0h-4h).
  static List<List<int>> cravingHeatmap(Iterable<Craving> cravings) {
    final grid = List.generate(7, (_) => List.filled(6, 0));
    for (final c in cravings) {
      final local = c.occurredAt.toLocal();
      grid[local.weekday - 1][local.hour ~/ 4]++;
    }
    return grid;
  }

  /// Weekday and slot with the most cravings, or null when there are none.
  static (int weekday, int slot)? riskiestSlot(List<List<int>> grid) {
    (int, int)? best;
    var max = 0;
    for (var d = 0; d < grid.length; d++) {
      for (var s = 0; s < grid[d].length; s++) {
        if (grid[d][s] > max) {
          max = grid[d][s];
          best = (d, s);
        }
      }
    }
    return best;
  }
}

/// Totals across the active addictions (current streaks).
class AddictionTotals {
  const AddictionTotals({
    required this.cleanDays,
    required this.moneySaved,
    required this.bestStreakDays,
  });

  factory AddictionTotals.of(Iterable<Addiction> addictions, DateTime now) {
    var days = 0;
    var money = 0.0;
    var best = 0;
    for (final a in addictions.where((a) => !a.isArchived)) {
      final clean = AddictionProgress.cleanDuration(a.streakStartedAt, now);
      days += AddictionProgress.fullCleanDays(clean);
      money += AddictionProgress.moneySaved(
        clean: clean,
        unitCost: a.unitCost,
        baselinePerDay: a.baselinePerDay,
      );
      final record = AddictionProgress.bestStreak(
        bestStreakSeconds: a.bestStreakSeconds,
        current: clean,
      ).inDays;
      if (record > best) best = record;
    }
    return AddictionTotals(cleanDays: days, moneySaved: money, bestStreakDays: best);
  }

  /// Sum of full clean days of every active addiction.
  final int cleanDays;
  final double moneySaved;
  final int bestStreakDays;
}
