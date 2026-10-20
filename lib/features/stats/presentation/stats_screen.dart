import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../../cravings/domain/craving.dart';
import '../../cravings/presentation/craving_providers.dart';
import '../../quests/presentation/quest_providers.dart';
import '../data/stats_repository.dart';
import '../domain/stats.dart';

part 'stats_screen.g.dart';

const _xpDays = 30;
const _questDays = 14;

@riverpod
Future<List<DayValue>> xpHistory(Ref ref) async {
  final now = DateTime.now();
  final since = DateTime(now.year, now.month, now.day - _xpDays + 1);
  final entries = await ref.watch(statsRepositoryProvider).fetchXpSince(since);
  return Stats.xpPerDay(entries, now, days: _xpDays);
}

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final addictions = ref.watch(myAddictionsProvider).value ?? const [];
    final cravings = ref.watch(recentCravingsProvider).value ?? const <Craving>[];
    final xp = ref.watch(xpHistoryProvider).value;
    final quests = ref.watch(activeQuestsProvider).value ?? const [];
    final logs = ref.watch(questLogsProvider).value ?? const [];

    final totals = AddictionTotals.of(addictions, now);
    final cravingStats = CravingStats.of(cravings);
    final grid = Stats.cravingHeatmap(cravings);
    final riskiest = Stats.riskiestSlot(grid);
    final questSeries = Stats.questCompletion(quests, logs, now, days: _questDays);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(xpHistoryProvider);
          ref.invalidate(recentCravingsProvider);
          ref.invalidate(questLogsProvider);
          ref.invalidate(myAddictionsProvider);
          await ref.read(xpHistoryProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.calendar_month,
                        label: l10n.statsCleanDays,
                        value: formatCount(totals.cleanDays),
                        color: AppColors.xp,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        icon: Icons.savings_outlined,
                        label: l10n.cardSaved,
                        value: formatChf(totals.moneySaved),
                        color: AppColors.money,
                      ),
                    ),
                    Expanded(
                      child: StatTile(
                        icon: Icons.emoji_events_outlined,
                        label: l10n.statsBestStreak,
                        value: l10n.durationDays(totals.bestStreakDays),
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: l10n.statsXpTitle(_xpDays),
              subtitle: xp == null
                  ? null
                  : l10n.statsXpTotal(xp.fold<double>(0, (s, d) => s + d.value).round()),
              child: xp == null
                  ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                  : BarChart(values: [for (final d in xp) d.value], color: AppColors.xp),
            ),
            const SizedBox(height: 12),
            if (quests.isNotEmpty) ...[
              _ChartCard(
                title: l10n.statsQuestsTitle(_questDays),
                child: BarChart(
                  values: [for (final d in questSeries) d.value],
                  max: 1,
                  color: AppColors.money,
                ),
              ),
              const SizedBox(height: 12),
            ],
            _ChartCard(
              title: l10n.statsCravingsTitle,
              subtitle: cravings.isEmpty
                  ? l10n.cravingJournalEmpty
                  : [
                      l10n.cravingStats(
                        cravingStats.resisted,
                        cravingStats.total,
                        cravingStats.resistedPercent,
                      ),
                      if (riskiest != null)
                        l10n.statsRiskiest(
                          l10n.statsWeekday('${riskiest.$1}'),
                          '${riskiest.$2 * 4}h-${riskiest.$2 * 4 + 4}h',
                        ),
                    ].join('\n'),
              child: cravings.isEmpty ? null : Heatmap(grid: grid),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.statsFootnote,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, this.subtitle, this.child});

  final String title;
  final String? subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}

/// Minimal bar chart (no dependency): one bar per value, oldest on the left.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values, required this.color, this.max});

  final List<double> values;
  final Color color;

  /// Top of the scale; defaults to the largest value.
  final double? max;

  @override
  Widget build(BuildContext context) {
    final top = max ?? values.fold<double>(0, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, v) in values.indexed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: FractionallySizedBox(
                  heightFactor: top <= 0 ? 0.02 : (v / top).clamp(0.02, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: i == values.length - 1 ? color : color.withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Weekday × 4-hour slot grid of cravings.
class Heatmap extends StatelessWidget {
  const Heatmap({super.key, required this.grid});

  final List<List<int>> grid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final max = grid.expand((row) => row).fold<int>(0, (m, v) => v > m ? v : m);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 36),
            for (var s = 0; s < 6; s++)
              Expanded(
                child: Text(
                  '${s * 4}h',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var d = 0; d < 7; d++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(l10n.statsWeekdayShort('$d'), style: theme.textTheme.labelSmall),
                ),
                for (var s = 0; s < 6; s++)
                  Expanded(
                    child: Container(
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: grid[d][s] == 0
                            ? AppColors.surface
                            : AppColors.hp.withValues(alpha: 0.2 + 0.8 * grid[d][s] / max),
                      ),
                      alignment: Alignment.center,
                      child: grid[d][s] == 0
                          ? null
                          : Text('${grid[d][s]}', style: theme.textTheme.labelSmall),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
