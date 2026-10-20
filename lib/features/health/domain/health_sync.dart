import '../../quests/domain/quest.dart';

/// What Health Connect reported for today.
class HealthReading {
  const HealthReading({this.steps, this.sleepMinutes, this.workoutMinutes});

  final int? steps;

  /// Sleep of the last night (sessions ending today).
  final int? sleepMinutes;

  /// Workouts recorded today.
  final int? workoutMinutes;

  bool get isEmpty => steps == null && sleepMinutes == null && workoutMinutes == null;
}

/// A quest value to write after a Health Connect sync.
class QuestSync {
  const QuestSync(this.questId, this.value);

  final String questId;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is QuestSync && other.questId == questId && other.value == value;

  @override
  int get hashCode => Object.hash(questId, value);

  @override
  String toString() => 'QuestSync($questId, $value)';
}

/// Values to write for today's quests: steps → steps, sleep → hours (one
/// decimal), sport → minutes. A synced value never lowers what the user
/// already entered by hand.
List<QuestSync> questSyncs(List<QuestProgress> today, HealthReading reading) {
  double? valueFor(QuestType type) => switch (type) {
    QuestType.steps => reading.steps?.toDouble(),
    QuestType.sleep => reading.sleepMinutes == null
        ? null
        : (reading.sleepMinutes! / 60 * 10).round() / 10,
    QuestType.sport => reading.workoutMinutes?.toDouble(),
    _ => null,
  };

  return [
    for (final p in today)
      if (valueFor(p.quest.type) case final value?)
        if (value > p.value) QuestSync(p.quest.id, value),
  ];
}

/// Quest types Health Connect can fill in.
const healthSyncedQuestTypes = {QuestType.steps, QuestType.sleep, QuestType.sport};

/// Window for "last night": sessions ending between 18:00 yesterday and now.
DateTime sleepWindowStart(DateTime now) {
  final local = now.toLocal();
  return DateTime(local.year, local.month, local.day - 1, 18);
}
