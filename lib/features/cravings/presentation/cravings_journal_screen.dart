import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../data/craving_repository.dart';
import '../domain/craving.dart';
import 'craving_providers.dart';
import 'craving_sheet.dart';

class CravingsJournalScreen extends ConsumerWidget {
  const CravingsJournalScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Craving c) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(cravingRepositoryProvider).delete(c.id);
      ref.invalidate(recentCravingsProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cravings = ref.watch(recentCravingsProvider);
    final labels = {
      for (final a in ref.watch(myAddictionsProvider).value ?? const []) a.id: a.label,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cravingJournalTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(recentCravingsProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            ...cravings.when(
              data: (items) {
                if (items.isEmpty) {
                  return [EmptyState(emoji: '📝', message: l10n.cravingJournalEmpty)];
                }
                final stats = CravingStats.of(items);
                return [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cravingStats(
                              stats.resisted,
                              stats.total,
                              stats.resistedPercent,
                            ),
                            style: theme.textTheme.titleMedium,
                          ),
                          if (stats.topTrigger != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.cravingTopTrigger(
                                '${stats.topTrigger!.emoji} '
                                '${cravingTriggerText(l10n, stats.topTrigger!)}',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final c in items)
                    Dismissible(
                      key: ValueKey(c.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete_outline),
                      ),
                      onDismissed: (_) => _delete(context, ref, c),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: (c.resisted ? AppColors.money : AppColors.hp)
                              .withValues(alpha: 0.18),
                          child: Text(c.trigger.emoji),
                        ),
                        title: Text(
                          '${labels[c.addictionId] ?? '—'} · '
                          '${l10n.cravingIntensity(c.intensity)}',
                        ),
                        subtitle: Text(
                          [
                            formatDateTime(c.occurredAt),
                            cravingTriggerText(l10n, c.trigger),
                            if (c.note != null) c.note!,
                          ].join(' · '),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              c.resisted ? l10n.cravingResistedTag : l10n.cravingGaveInTag,
                              style: TextStyle(
                                color: c.resisted ? AppColors.money : AppColors.hp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (c.xpAwarded > 0)
                              Text(
                                l10n.xpGain(c.xpAwarded),
                                style: const TextStyle(color: AppColors.xp),
                              ),
                          ],
                        ),
                      ),
                    ),
                ];
              },
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(recentCravingsProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
