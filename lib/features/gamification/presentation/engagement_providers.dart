import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/engagement_repository.dart';
import '../domain/badges.dart';

part 'engagement_providers.g.dart';

@riverpod
Future<bool> pledgedToday(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return false;
  return ref.watch(engagementRepositoryProvider).hasPledgedOn(DateTime.now());
}

@riverpod
Future<List<UnlockedBadge>> myBadges(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return const [];
  return ref.watch(engagementRepositoryProvider).fetchBadges(userId);
}
