import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/craving_repository.dart';
import '../domain/craving.dart';

part 'craving_providers.g.dart';

@riverpod
Future<List<Craving>> recentCravings(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return const [];
  return ref.watch(cravingRepositoryProvider).fetchRecent();
}
