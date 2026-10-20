import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../../quests/data/quest_repository.dart';
import '../../quests/domain/quest.dart';
import '../../quests/presentation/quest_providers.dart';
import '../data/health_repository.dart';
import '../domain/health_sync.dart';

part 'health_providers.g.dart';

/// Health Connect state for the quests screen.
class HealthState {
  const HealthState(this.availability, {this.hasAccess = false});

  final HealthAvailability availability;
  final bool hasAccess;
}

@riverpod
Future<HealthState> healthState(Ref ref) async {
  final repo = ref.watch(healthRepositoryProvider);
  final availability = await repo.availability();
  if (availability != HealthAvailability.available) return HealthState(availability);
  return HealthState(availability, hasAccess: await repo.hasAccess());
}

/// Fills today's steps / sleep / sport quests from Health Connect. Returns
/// how many quests were updated (0 when access is missing or nothing changed).
Future<int> syncQuestsFromHealth(Ref ref) async {
  final repo = ref.read(healthRepositoryProvider);
  final state = await ref.read(healthStateProvider.future);
  if (!state.hasAccess) return 0;

  final day = await ref.read(questDayProvider.future);
  final relevant = day.items
      .where((p) => healthSyncedQuestTypes.contains(p.quest.type))
      .toList();
  if (relevant.isEmpty) return 0;

  final reading = await repo.readToday(DateTime.now());
  final syncs = questSyncs(relevant, reading);
  final quests = ref.read(questRepositoryProvider);
  for (final s in syncs) {
    await quests.log(s.questId, s.value);
  }
  if (syncs.isNotEmpty) {
    ref.invalidate(questLogsProvider);
    ref.invalidate(playerStatsProvider);
  }
  return syncs.length;
}

/// Sync entry point for widgets (Riverpod function provider, re-run on demand
/// with `ref.invalidate(healthSyncProvider)`).
@riverpod
Future<int> healthSync(Ref ref) async {
  // Re-sync whenever the active quests change.
  await ref.watch(activeQuestsProvider.future);
  return syncQuestsFromHealth(ref);
}

/// Today's quests that Health Connect can fill in.
bool hasHealthQuests(QuestDay day) =>
    day.items.any((p) => healthSyncedQuestTypes.contains(p.quest.type));
