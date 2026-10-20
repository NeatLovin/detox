import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/addiction_repository.dart';
import '../domain/addiction.dart';

part 'addiction_providers.g.dart';

/// All addictions of the signed-in user, archived ones included.
@riverpod
Future<List<Addiction>> myAddictions(Ref ref) async {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) return const [];
  return ref.watch(addictionRepositoryProvider).fetchMine();
}

@riverpod
Future<List<Addiction>> activeAddictions(Ref ref) async {
  final all = await ref.watch(myAddictionsProvider.future);
  return all.where((a) => !a.isArchived).toList();
}
