import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../quests/presentation/quest_providers.dart';
import '../data/health_repository.dart';
import 'health_providers.dart';

/// Quests screen card: connect Health Connect, or show that it syncs.
/// Hidden when the phone does not support it or no quest can be synced.
class HealthCard extends ConsumerStatefulWidget {
  const HealthCard({super.key});

  @override
  ConsumerState<HealthCard> createState() => _HealthCardState();
}

class _HealthCardState extends ConsumerState<HealthCard> {
  bool _busy = false;

  Future<void> _connect() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final granted = await ref.read(healthRepositoryProvider).requestAccess();
      ref.invalidate(healthStateProvider);
      if (!granted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.healthDenied)));
        return;
      }
      ref.invalidate(healthSyncProvider);
      final updated = await ref.read(healthSyncProvider.future);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.healthSynced(updated))),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(healthStateProvider).value;
    final day = ref.watch(questDayProvider).value;
    if (state == null || day == null || !hasHealthQuests(day)) {
      return const SizedBox.shrink();
    }

    if (state.hasAccess) {
      // Keeps today's synced quests fresh while the screen is shown.
      ref.watch(healthSyncProvider);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Icon(Icons.favorite, size: 16, color: AppColors.money),
            const SizedBox(width: 6),
            Expanded(
              child: Text(l10n.healthConnected, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      );
    }

    final notInstalled = state.availability == HealthAvailability.notInstalled;
    if (state.availability == HealthAvailability.unsupported) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_heart_outlined, color: AppColors.money),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.healthTitle, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l10n.healthBody),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _busy
                    ? null
                    : notInstalled
                    ? () => ref.read(healthRepositoryProvider).install()
                    : _connect,
                child: Text(notInstalled ? l10n.healthInstall : l10n.healthConnect),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
