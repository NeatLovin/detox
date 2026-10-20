import '../../../core/utils/day.dart';

/// Must match the CHECK constraint on `daily_quests.type`.
enum QuestType {
  water('water'),
  sport('sport'),
  sleep('sleep'),
  steps('steps'),
  meditation('meditation'),
  reading('reading'),
  noScreen('no_screen'),
  custom('custom');

  const QuestType(this.dbValue);

  final String dbValue;

  static QuestType fromDb(String? value) => QuestType.values.firstWhere(
    (t) => t.dbValue == value,
    orElse: () => QuestType.custom,
  );
}

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.type,
    required this.label,
    required this.unitLabel,
    required this.target,
    this.archivedAt,
    required this.createdAt,
  });

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
    id: json['id'] as String,
    type: QuestType.fromDb(json['type'] as String?),
    label: json['label'] as String,
    unitLabel: json['unit_label'] as String,
    target: (json['target'] as num).toDouble(),
    archivedAt: json['archived_at'] == null
        ? null
        : DateTime.parse(json['archived_at'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  final String id;
  final QuestType type;
  final String label;
  final String unitLabel;
  final double target;
  final DateTime? archivedAt;
  final DateTime createdAt;

  bool get isArchived => archivedAt != null;
}

class QuestLog {
  const QuestLog({
    required this.questId,
    required this.day,
    required this.value,
    required this.done,
    this.xpAwarded = false,
  });

  factory QuestLog.fromJson(Map<String, dynamic> json) => QuestLog(
    questId: json['quest_id'] as String,
    day: parseDay(json['day'] as String),
    value: (json['value'] as num).toDouble(),
    done: json['done'] as bool? ?? false,
    xpAwarded: json['xp_awarded'] as bool? ?? false,
  );

  final String questId;
  final DateTime day;
  final double value;
  final bool done;

  /// True once this quest-day has paid its XP (never twice).
  final bool xpAwarded;
}

/// Formats a quest value without a useless ".0" (7.5 h, 8 verres).
String formatQuestValue(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

class QuestDraft {
  const QuestDraft({
    required this.type,
    required this.label,
    required this.unitLabel,
    required this.target,
  });

  final QuestType type;
  final String label;
  final String unitLabel;
  final double target;
}

/// Today's view of one quest: progress, completion and streak.
class QuestProgress {
  const QuestProgress({
    required this.quest,
    required this.value,
    required this.streak,
    this.xpAwarded = false,
  });

  /// Builds the view of [quest] for [today] from its logs.
  factory QuestProgress.of(
    DailyQuest quest,
    Iterable<QuestLog> logs,
    DateTime today,
  ) {
    final mine = logs.where((l) => l.questId == quest.id).toList();
    final todayKey = dayKey(today);
    final todayLog = mine.where((l) => dayKey(l.day) == todayKey).firstOrNull;
    return QuestProgress(
      quest: quest,
      value: todayLog?.value ?? 0,
      xpAwarded: todayLog?.xpAwarded ?? false,
      streak: consecutiveDays(
        mine.where((l) => l.done).map((l) => l.day),
        today,
      ),
    );
  }

  final DailyQuest quest;
  final double value;
  final int streak;

  /// Today's XP already paid (a quest-day pays once, even after undo/redo).
  final bool xpAwarded;

  bool get done => value >= quest.target;

  /// 0..1, for a progress bar.
  double get ratio => quest.target <= 0 ? 0 : (value / quest.target).clamp(0.0, 1.0);
}

/// Summary of the day across all active quests.
class QuestDay {
  const QuestDay(this.items);

  final List<QuestProgress> items;

  int get doneCount => items.where((p) => p.done).length;
  int get total => items.length;
  bool get allDone => items.isNotEmpty && doneCount == total;
}
