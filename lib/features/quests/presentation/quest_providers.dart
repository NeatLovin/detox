import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/quest_repository.dart';
import '../domain/quest.dart';

part 'quest_providers.g.dart';

/// Days of history loaded for the streaks.
const questHistoryDays = 60;

@riverpod
Future<List<DailyQuest>> activeQuests(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return const [];
  final all = await ref.watch(questRepositoryProvider).fetchMine();
  return all.where((q) => !q.isArchived).toList();
}

@riverpod
Future<List<QuestLog>> questLogs(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return const [];
  final now = DateTime.now();
  return ref
      .watch(questRepositoryProvider)
      .fetchLogsSince(DateTime(now.year, now.month, now.day - questHistoryDays));
}

/// Today's progress of every active quest.
@riverpod
Future<QuestDay> questDay(Ref ref) async {
  final quests = await ref.watch(activeQuestsProvider.future);
  final logs = await ref.watch(questLogsProvider.future);
  final today = DateTime.now();
  return QuestDay([for (final q in quests) QuestProgress.of(q, logs, today)]);
}
