import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/sos_repository.dart';
import '../domain/sos.dart';

part 'sos_providers.g.dart';

/// Realtime SOS alerts of the squad (newest first).
@riverpod
Stream<List<SosAlert>> squadSosAlerts(Ref ref) async* {
  final squad = await ref.watch(currentSquadProvider.future);
  if (squad == null) {
    yield const [];
    return;
  }
  yield* ref.watch(sosRepositoryProvider).watchSquadAlerts(squad.id);
}

/// Realtime supports received by one SOS.
@riverpod
Stream<List<SosSupport>> sosSupports(Ref ref, String alertId) =>
    ref.watch(sosRepositoryProvider).watchSupports(alertId);
