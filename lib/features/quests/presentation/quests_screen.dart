import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gamification/domain/rewards.dart';
import '../../health/presentation/health_card.dart';
import '../../health/presentation/health_providers.dart';
import '../data/quest_repository.dart';
import '../domain/quest.dart';
import '../domain/quest_catalog.dart';
import 'quest_form_sheet.dart';
import 'quest_providers.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(activeQuestsProvider);
    ref.invalidate(questLogsProvider);
    ref.invalidate(healthStateProvider);
    ref.invalidate(healthSyncProvider);
    await ref.read(questDayProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final day = ref.watch(questDayProvider);
    final count = day.value?.total ?? 0;
    final canAdd = day.hasValue && count < QuestLimits.maxActive;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.questsTitle)),
      floatingActionButton: day.hasValue
          ? FloatingActionButton.extended(
              onPressed: canAdd
                  ? () => showQuestFormSheet(context)
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.questsLimit(QuestLimits.maxActive)),
                      ),
                    ),
              icon: const Icon(Icons.add),
              label: Text(l10n.questsAdd),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            ...day.when(
              data: (summary) => summary.items.isEmpty
                  ? [
                      EmptyState(
                        emoji: '🎯',
                        message: l10n.questsEmpty,
                        action: FilledButton.icon(
                          onPressed: () => showQuestFormSheet(context),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.questsAdd),
                        ),
                      ),
                    ]
                  : [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.allDone
                                    ? l10n.questsAllDone
                                    : l10n.questsSummary(
                                        summary.doneCount,
                                        summary.total,
                                      ),
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: summary.total == 0
                                    ? 0
                                    : summary.doneCount / summary.total,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.money,
                              ),
                              if (!summary.allDone) ...[
                                const SizedBox(height: 8),
                                Text(
                                  l10n.questsAllDoneHint(
                                    Rewards.questsAllDone.xp,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const HealthCard(),
                      for (final (index, progress) in summary.items.indexed) ...[
                        QuestCard(
                          key: ValueKey(progress.quest.id),
                          progress: progress,
                        ).animate().fadeIn(delay: (60 * index).ms),
                        const SizedBox(height: 12),
                      ],
                    ],
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(activeQuestsProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestCard extends ConsumerStatefulWidget {
  const QuestCard({super.key, required this.progress});

  final QuestProgress progress;

  @override
  ConsumerState<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends ConsumerState<QuestCard> {
  bool _busy = false;

  DailyQuest get _quest => widget.progress.quest;

  Future<void> _set(double value) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final alreadyPaid = widget.progress.xpAwarded;
    setState(() => _busy = true);
    try {
      final log = await ref
          .read(questRepositoryProvider)
          .log(_quest.id, value < 0 ? 0 : value);
      ref.invalidate(questLogsProvider);
      ref.invalidate(playerStatsProvider);
      if (!alreadyPaid && log.xpAwarded) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.xpGain(Rewards.quest.xp))),
        );
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _askValue() async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: widget.progress.value == 0 ? '' : formatQuestValue(widget.progress.value),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.questSetValueTitle(_quest.label)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: _quest.unitLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.trim().replaceAll(',', '.')),
            ),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    // Not disposed here: the dialog may still be animating out.
    if (value != null && mounted) await _set(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = widget.progress;
    final preset = QuestCatalog.of(_quest.type);
    final input = QuestCatalog.inputFor(_quest);
    final done = progress.done;

    final controls = switch (input) {
      QuestInput.toggle => FilledButton.tonalIcon(
        onPressed: _busy ? null : () => _set(done ? 0 : _quest.target),
        icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
        label: Text(l10n.questDone),
      ),
      QuestInput.number => FilledButton.tonal(
        onPressed: _busy ? null : _askValue,
        child: Text(
          '${formatQuestValue(progress.value)} / ${formatQuestValue(_quest.target)} ${_quest.unitLabel}',
        ),
      ),
      QuestInput.stepper => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            onPressed: _busy || progress.value <= 0
                ? null
                : () => _set(progress.value - preset.step),
            icon: const Icon(Icons.remove),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${formatQuestValue(progress.value)} / ${formatQuestValue(_quest.target)}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton.filled(
            onPressed: _busy ? null : () => _set(progress.value + preset.step),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onLongPress: () => showQuestFormSheet(context, quest: _quest),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(preset.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _quest.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          input == QuestInput.toggle
                              ? l10n.questTypeLabel(_quest.type.dbValue)
                              : '${formatQuestValue(_quest.target)} ${_quest.unitLabel}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (progress.streak > 0)
                    Chip(
                      label: Text(l10n.questStreak(progress.streak)),
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    tooltip: l10n.commonEdit,
                    onPressed: () => showQuestFormSheet(context, quest: _quest),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.ratio,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
                color: done ? AppColors.money : AppColors.xp,
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: controls),
            ],
          ),
        ),
      ),
    );
  }
}
