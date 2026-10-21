import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../addictions/domain/addiction_catalog.dart';
import '../../addictions/domain/addiction_progress.dart';
import '../../addictions/presentation/addiction_providers.dart';
import '../data/health_timeline_providers.dart';
import '../domain/health_timeline.dart';
import 'timeline_widgets.dart';

/// Full timeline of one of the user's addictions: reached milestones in
/// color, upcoming ones with a countdown.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key, required this.addictionId});

  final String addictionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    final addiction = ref
        .watch(myAddictionsProvider)
        .value
        ?.where((a) => a.id == addictionId)
        .firstOrNull;
    final timelines = ref.watch(healthTimelinesProvider).value;

    if (addiction == null || timelines == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final timeline = timelines.of(addiction.type);
    if (timeline == null) {
      return Scaffold(
        appBar: AppBar(title: Text(addiction.label)),
        body: EmptyState(emoji: '🌱', message: l10n.timelineEmpty),
      );
    }

    final clean = AddictionProgress.cleanDuration(addiction.streakStartedAt, now);
    final next = timeline.next(clean);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AddictionCatalog.of(addiction.type).emoji}  '
          '${timeline.kind == TimelineKind.body ? l10n.timelineBodyTitle : l10n.timelineProgressTitle}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (timeline.warning != null) ...[
            Card(
              color: AppColors.hpLow.withValues(alpha: 0.15),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: AppColors.hpLow),
                title: Text(timeline.warning!, style: theme.textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            l10n.timelineHeader(addiction.label, timeline.reached(clean).length, timeline.milestones.length),
            style: theme.textTheme.titleMedium,
          ),
          if (next != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: timeline.progressToNext(clean),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: AppColors.hp,
            ),
          ],
          const SizedBox(height: 16),
          for (final (index, m) in timeline.milestones.indexed)
            _MilestoneTile(
              milestone: m,
              reached: m.after <= clean,
              isNext: identical(m, next),
              countdown: m.after > clean ? timeUntil(l10n, m.after - clean) : null,
              isLast: index == timeline.milestones.length - 1,
            ),
          const SizedBox(height: 16),
          Text(timelines.disclaimer, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          if (timeline.source != null && timeline.sourceUrl != null)
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(timeline.sourceUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.timelineSource(timeline.source!)),
            ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.reached,
    required this.isNext,
    required this.countdown,
    required this.isLast,
  });

  final HealthMilestone milestone;
  final bool reached;
  final bool isNext;
  final String? countdown;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = reached ? AppColors.money : (isNext ? AppColors.hp : Colors.white24);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: reached ? 0.25 : 0.12),
                    border: Border.all(color: color, width: isNext ? 2 : 1),
                  ),
                  child: Opacity(
                    opacity: reached || isNext ? 1 : 0.5,
                    child: Text(milestone.emoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Opacity(
                opacity: reached || isNext ? 1 : 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(milestone.title, style: theme.textTheme.titleSmall),
                        ),
                        Text(
                          reached ? '✓ ${afterLabel(l10n, milestone.after)}' : countdown ?? '',
                          style: theme.textTheme.labelSmall?.copyWith(color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(milestone.body, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
