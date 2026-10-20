import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button_spinner.dart';
import '../data/engagement_repository.dart';
import '../domain/rewards.dart';
import 'engagement_providers.dart';

/// Morning pledge: one tap, once a day, shown in the global feed.
class PledgeCard extends ConsumerStatefulWidget {
  const PledgeCard({super.key});

  @override
  ConsumerState<PledgeCard> createState() => _PledgeCardState();
}

class _PledgeCardState extends ConsumerState<PledgeCard> {
  bool _busy = false;

  Future<void> _pledge() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final created = await ref.read(engagementRepositoryProvider).pledge();
      ref.invalidate(pledgedTodayProvider);
      ref.invalidate(playerStatsProvider);
      ref.invalidate(myBadgesProvider);
      if (created) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.xpGain(Rewards.pledge.xp))),
        );
      }
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
    final pledged = ref.watch(pledgedTodayProvider);
    if (!pledged.hasValue) return const SizedBox.shrink();

    if (pledged.requireValue) {
      return Card(
        child: ListTile(
          leading: const Text('🤝', style: TextStyle(fontSize: 28)),
          title: Text(l10n.pledgeDone),
        ),
      ).animate().fadeIn();
    }

    return Card(
      color: AppColors.gold.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pledgeTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.pledgeBody),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _pledge,
              child: _busy
                  ? const ButtonSpinner()
                  : Text(
                      '${l10n.pledgeButton}  ·  ${l10n.xpGain(Rewards.pledge.xp)}',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
