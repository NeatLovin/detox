import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../../../shared/widgets/xp_bar.dart';
import '../../domain/addiction.dart';
import '../../domain/addiction_catalog.dart';
import '../../domain/addiction_progress.dart';

/// Live card: re-renders every second from a local ticker, no network call.
class AddictionCard extends ConsumerWidget {
  const AddictionCard({
    super.key,
    required this.addiction,
    required this.onRelapse,
  });

  final Addiction addiction;
  final VoidCallback onRelapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    return AddictionCardView(
      addiction: addiction,
      now: now,
      onRelapse: onRelapse,
    );
  }
}

class AddictionCardView extends StatelessWidget {
  const AddictionCardView({
    super.key,
    required this.addiction,
    required this.now,
    required this.onRelapse,
  });

  final Addiction addiction;
  final DateTime now;
  final VoidCallback onRelapse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final clean = AddictionProgress.cleanDuration(
      addiction.streakStartedAt,
      now,
    );
    final parts = AddictionProgress.split(clean);
    final saved = AddictionProgress.moneySaved(
      clean: clean,
      unitCost: addiction.unitCost,
      baselinePerDay: addiction.baselinePerDay,
    );
    final avoided = AddictionProgress.unitsAvoided(
      clean: clean,
      baselinePerDay: addiction.baselinePerDay,
    );
    final record = AddictionProgress.bestStreak(
      bestStreakSeconds: addiction.bestStreakSeconds,
      current: clean,
    );
    final next = AddictionProgress.nextMilestone(clean);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  AddictionCatalog.of(addiction.type).emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    addiction.label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (addiction.isPrivate)
                  Tooltip(
                    message: l10n.cardPrivate,
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.lock, size: 14),
                      label: Text(l10n.cardPrivate),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cardCleanFor,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.durationCompact(
                  parts.days,
                  parts.hours,
                  parts.minutes,
                  parts.seconds,
                ),
                key: const ValueKey('clean-timer'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.savings_outlined,
                    label: l10n.cardSaved,
                    value: formatChf(saved),
                    color: AppColors.money,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    icon: Icons.block,
                    label: l10n.cardAvoided,
                    value:
                        '${formatCount(AddictionProgress.roundedUnits(avoided))} '
                        '${addiction.unitLabel}',
                  ),
                ),
                Expanded(
                  child: StatTile(
                    icon: Icons.emoji_events_outlined,
                    label: l10n.cardRecord,
                    value: l10n.durationDays(record.inDays),
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (next != null) ...[
              Row(
                children: [
                  Text(
                    l10n.cardNextMilestone(next.milestone.days),
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  Text(
                    l10n.cardMilestoneBonus(next.milestone.bonusXp),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.xp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ProgressBar(
                value: next.ratio,
                height: 8,
                color: theme.colorScheme.primary,
              ),
            ] else
              Text(
                l10n.cardAllMilestones,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge,
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRelapse,
                icon: const Icon(Icons.replay),
                label: Text(l10n.relapseButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
