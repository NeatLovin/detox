import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/session/session_providers.dart';
import '../data/sos_repository.dart';
import '../domain/sos.dart';

part 'sos_providers.g.dart';

/// Realtime SOS alerts of every public player (newest first).
@riverpod
Stream<List<SosAlert>> sosAlerts(Ref ref) async* {
  final userId = await ref.watch(authStateProvider.future);
  if (userId == null) {
    yield const [];
    return;
  }
  yield* ref.watch(sosRepositoryProvider).watchAlerts();
}

/// Realtime supports received by one SOS.
@riverpod
Stream<List<SosSupport>> sosSupports(Ref ref, String alertId) =>
    ref.watch(sosRepositoryProvider).watchSupports(alertId);
